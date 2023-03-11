// Bicep Module for the creation of a Synapse Spark Pool

@description('Required. Spark Pool Purpose. The lenght must not exceed 10 characters')
@maxLength(10)
param sparkPoolPurpose string

@description('Required. Name of the Synapse Workspace.')
@minLength(5)
@maxLength(50)
param synapseWorkspaceName string

@description('Optional. Location for the Synapse Workspace. Defafults to the ResourceGroup location')
param location string = resourceGroup().location

@description('Required. Resource tags.')
param sparkPoolTags object = {}

@description('Optional. Enable Autoscale feature.')
param sparkAutoScaleEnabled bool = true

@description('Optional. Maximum number of nodes to be allocated in the specified Spark pool. This parameter must be specified when Auto-scale is enabled.')
@maxValue(200)
@minValue(3)
param sparkAutoScaleMaxNodeCount int = 6

@description('Optional. Minimum number of nodes to be allocated in the specified Spark pool. This parameter must be specified when Auto-Scale is enabled.')
@maxValue(199)
@minValue(3)
param sparkAutoScaleMinNodeCount int = 3

@description('Optional. Whether compute isolation is required or not. (Feature not available in all regions)')
@allowed([
  false
])
param sparkIsolatedComputeEnabled bool = false

@description('Number of nodes to be allocated in the Spark pool (If Autoscale is not enabled)')
param sparkNodeCount int = 0

@description('Optional. The kind of nodes that the Spark Pool provides.')
@allowed([
  'MemoryOptimized'
  'HardwareAccelerated'
])
param sparkNodeSizeFamily string = 'MemoryOptimized'

@description('Optional. The level of compute power that each node in the Big Data pool has.')
@allowed([
  'Small'
  'Medium'
//  'Large'
//  'XLarge'
//  'XXLarge'
])
param sparkNodeSize string = 'Medium'

@description('Optional. Whether auto-pausing is enabled for the Big Data pool.')
param sparkAutoPauseEnabled bool = true

@description('Optional. Number of minutes of idle time before the Big Data pool is automatically paused.')
param sparkAutoPauseDelayInMinutes int = 7

@description('Optional. The Apache Spark version.')
@allowed([
  '3.3'
  '3.2'
  '3.1'
])
param sparkVersion string = '3.3'

@description('Optional. Indicates whether Dynamic Executor Allocation is enabled or not')
param sparkDynamicExecutorEnabled bool = true

@description('Optional. The minimum number of executors alloted')
@minValue(1)
@maxValue(198)
param sparkMinExecutorCount int = 1

@description('Optional. The Maximum number of executors alloted')
@minValue(2)
@maxValue(199)
param sparkMaxExecutorCount int = 3

@description('Optional. The allocated Cache Size (in percentage)')
@minValue(0)
@maxValue(100)
param sparkCacheSize int = 25

@description('Optional. The filename of the spark config properties file.')
param sparkConfigPropertiesFileName string = ''

@description('Optional. The spark config properties.')
param sparkConfigPropertiesContent string = ''

@description('Optional. Whether session level packages enabled.	')
param sessionLevelPackagesEnabled bool = false

// Format the Spark Pool Name (Max length is 15 characters)
var sparkPoolName = 'synsp-${sparkPoolPurpose}}'

// Get the existing Synapse Workspace (Used for Output purposes mainly)
resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: synapseWorkspaceName
}

// Create Spark Pool Resource
resource sparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  parent: synapseWorkspace
  name: sparkPoolName
  location: location
  tags: sparkPoolTags
  properties: {
    nodeCount: sparkNodeCount
    nodeSizeFamily: sparkNodeSizeFamily
    nodeSize: sparkNodeSize
    autoScale: {
      enabled: sparkAutoScaleEnabled
      minNodeCount: sparkAutoScaleMinNodeCount
      maxNodeCount: sparkAutoScaleMaxNodeCount
    }
    autoPause: {
      enabled: sparkAutoPauseEnabled
      delayInMinutes: sparkAutoPauseDelayInMinutes
    }
    sparkVersion: sparkVersion
    sparkConfigProperties: {
      filename: sparkConfigPropertiesFileName
      content: sparkConfigPropertiesContent
    }
    isComputeIsolationEnabled: sparkIsolatedComputeEnabled
    sessionLevelPackagesEnabled: sessionLevelPackagesEnabled
    dynamicExecutorAllocation: {
      enabled: sparkDynamicExecutorEnabled
      minExecutors: sparkMinExecutorCount
      maxExecutors: sparkMaxExecutorCount
    }
    cacheSize: sparkCacheSize
  }
}

output sparkPoolName string = sparkPoolName
output poolURL string = 'https://${synapseWorkspaceName}.dev.azuresynapse.net'
output synapseWorkspaceName string = synapseWorkspace.name
output SynapseWorkSpaceResourceId string = synapseWorkspace.id
