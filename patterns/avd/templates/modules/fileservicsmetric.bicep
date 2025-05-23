param AutoMitigate bool
param Enabled bool
param Environment string
param Location string
param StorageAccountResourceID string
param MetricAlertsFileShares array
param ActionGroupID string
param Tags object

// Help ensure entire deployment name is under 64 characters
var StorAcctNameOrig = split(StorageAccountResourceID, '/')[8]
var StorAcctName = length(StorAcctNameOrig) < 20 ? StorAcctNameOrig : skip(StorAcctNameOrig, length(StorAcctNameOrig)-20)

var FileServicesResourceID = '${StorageAccountResourceID}/fileServices/default'

module metricAlerts_FileServices '../carml/1.3.0/Microsoft.Insights/metricAlerts/deploy.bicep' = [for i in range(0, length(MetricAlertsFileShares)): {
  name: 'c_${MetricAlertsFileShares[i].name}-${StorAcctName}-${Environment}'
  params: {
    enableDefaultTelemetry: false
    name: '${MetricAlertsFileShares[i].displayName}-${StorAcctName}-${Environment}'
    criterias: MetricAlertsFileShares[i].criteria.allOf
    location: 'global'
    alertDescription: MetricAlertsFileShares[i].description
    severity:MetricAlertsFileShares[i].severity
    enabled: Enabled
    scopes: [FileServicesResourceID]  //Assuming first VM Resource ID has same RG for all
    evaluationFrequency: MetricAlertsFileShares[i].evaluationFrequency
    windowSize: MetricAlertsFileShares[i].windowSize
    autoMitigate: AutoMitigate
    tags: contains(Tags, 'Microsoft.Insights/metricAlerts') ? Tags['Microsoft.Insights/metricAlerts'] : {}
    targetResourceType: MetricAlertsFileShares[i].targetResourceType
    targetResourceRegion: Location
    actions: [
      {
        actionGroupId: ActionGroupID
      }
    ]

  }
}]
