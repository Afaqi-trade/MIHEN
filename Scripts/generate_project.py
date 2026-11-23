#!/usr/bin/env python3
"""Deterministic Xcode project generator using only Python's standard library."""
from pathlib import Path
import hashlib,json
root=Path(__file__).resolve().parents[1]
objects={}
def oid(key):return hashlib.sha1(key.encode()).hexdigest()[:24].upper()
def put(key,isa,**values):
 i=oid(key);objects[i]={'isa':isa,**values};return i
def file(path,kind=None):
 ext=Path(path).suffix
 types={'.swift':'sourcecode.swift','.xcassets':'folder.assetcatalog','.xcstrings':'text.json.xcstrings','.plist':'text.plist.xml','.xcprivacy':'text.xml','.storyboard':'file.storyboard','.entitlements':'text.plist.entitlements'}
 return put('file:'+path,'PBXFileReference',lastKnownFileType=kind or types.get(ext,'text'),path=path,sourceTree='<group>')
app_sources=sorted(str(p.relative_to(root)) for p in (root/'MIHEN').rglob('*.swift'))+sorted(str(p.relative_to(root)) for p in (root/'Core').glob('*.swift'))
screen_shared=sorted(str(p.relative_to(root)) for p in (root/'ScreenTimeShared').glob('*.swift'))
app_sources+=screen_shared
monitor_sources=['MIHENActivityMonitor/UsageMonitor.swift','Core/UsageLimitPolicy.swift','Core/PlanError.swift']+screen_shared
widget_sources=['MIHENWidget/MIHENWidget.swift','MIHEN/Services/SharedWidget.swift','MIHEN/Services/Localization.swift']+sorted(str(p.relative_to(root)) for p in (root/'Core').glob('*.swift'))
unit_sources=['MIHENTests/CoreScenarios.swift','MIHENTests/PersistenceTests.swift','MIHENTests/UsageLimitRepositoryTests.swift','MIHENTests/ReportPerformanceTests.swift']
ui_sources=['MIHENUITests/MIHENUITests.swift']
coretests='\n'.join(p.read_text().replace('@testable import MIHENCore','@testable import MIHEN') for p in sorted((root/'Tests/MIHENCoreTests').glob('*.swift')))
(root/'MIHENTests/CoreScenarios.swift').write_text('// Generated from Tests/MIHENCoreTests.\n'+coretests)
app_resources=['MIHEN/Localization/InfoPlist.xcstrings','MIHEN/Assets.xcassets','MIHEN/Localization/Localizable.xcstrings','MIHEN/Resources/LaunchScreen.storyboard','MIHEN/Resources/PrivacyInfo.xcprivacy']
monitor_resources=['MIHENActivityMonitor/PrivacyInfo.xcprivacy']
widget_resources=['MIHEN/Localization/Localizable.xcstrings','MIHENWidget/PrivacyInfo.xcprivacy']
all_paths=sorted(set(app_sources+widget_sources+monitor_sources+unit_sources+ui_sources+app_resources+widget_resources+monitor_resources+['MIHEN/Resources/Info.plist','MIHEN/Resources/MIHEN.entitlements','MIHENWidget/Info.plist','MIHENWidget/MIHENWidget.entitlements','MIHENActivityMonitor/Info.plist','MIHENActivityMonitor/MIHENActivityMonitor.entitlements']))
refs={p:file(p) for p in all_paths}
products={}
for name,ext,typ in [('MIHEN','app','wrapper.application'),('MIHENWidget','appex','wrapper.app-extension'),('MIHENActivityMonitor','appex','wrapper.app-extension'),('MIHENTests','xctest','wrapper.cfbundle'),('MIHENUITests','xctest','wrapper.cfbundle')]:
 products[name]=put('product:'+name,'PBXFileReference',explicitFileType=typ,includeInIndex=0,path=name+'.'+ext,sourceTree='BUILT_PRODUCTS_DIR')
product_group=put('group:products','PBXGroup',children=list(products.values()),name='Products',sourceTree='<group>')
source_group=put('group:sources','PBXGroup',children=list(refs.values()),name='Source files',sourceTree='<group>')
main_group=put('group:root','PBXGroup',children=[source_group,product_group],sourceTree='<group>')
def phase(name,kind,paths):
 builds=[put(name+':'+p,'PBXBuildFile',fileRef=refs[p]) for p in paths]
 return put(name,kind,buildActionMask=2147483647,files=builds,runOnlyForDeploymentPostprocessing=0)
def configs(name,settings):
 ids=[]
 for config in ['Debug','Release']:
  s=dict(settings)
  s.update({'SWIFT_OPTIMIZATION_LEVEL':'-Onone' if config=='Debug' else '-O','DEBUG_INFORMATION_FORMAT':'dwarf' if config=='Debug' else 'dwarf-with-dsym','SWIFT_ACTIVE_COMPILATION_CONDITIONS':'DEBUG $(inherited)' if config=='Debug' else '$(inherited)'})
  if name=='MIHEN':s['ENABLE_TESTABILITY']='YES' if config=='Debug' else 'NO'
  ids.append(put('config:'+name+config,'XCBuildConfiguration',name=config,buildSettings=s))
 return put('configs:'+name,'XCConfigurationList',buildConfigurations=ids,defaultConfigurationIsVisible=0,defaultConfigurationName='Release')
common={'SDKROOT':'iphoneos','IPHONEOS_DEPLOYMENT_TARGET':'18.0','SWIFT_VERSION':'6.0','SWIFT_STRICT_CONCURRENCY':'complete','CLANG_ENABLE_MODULES':'YES','CLANG_ENABLE_OBJC_ARC':'YES','CODE_SIGN_STYLE':'Automatic','DEVELOPMENT_TEAM':'PY75Z73294','MIHEN_APP_GROUP':'group.com.afaqitrade.mihen','MIHEN_APP_PROFILE_NAME':'','MIHEN_WIDGET_PROFILE_NAME':'','MIHEN_MONITOR_PROFILE_NAME':'','MARKETING_VERSION':'1.0.0','CURRENT_PROJECT_VERSION':'1','TARGETED_DEVICE_FAMILY':'1','SUPPORTED_PLATFORMS':'iphoneos iphonesimulator','SUPPORTS_MACCATALYST':'NO','ENABLE_USER_SCRIPT_SANDBOXING':'YES','LOCALIZATION_PREFERS_STRING_CATALOGS':'YES','SWIFT_EMIT_LOC_STRINGS':'YES'}
targets={n:oid('target:'+n) for n in products}
def dependency(owner,target):
 proxy=put('proxy:'+owner+target,'PBXContainerItemProxy',containerPortal=oid('project'),proxyType=1,remoteGlobalIDString=targets[target],remoteInfo=target)
 return put('dependency:'+owner+target,'PBXTargetDependency',target=targets[target],targetProxy=proxy)
for name,sources,resources in [('MIHEN',app_sources,app_resources),('MIHENWidget',widget_sources,widget_resources),('MIHENActivityMonitor',monitor_sources,monitor_resources),('MIHENTests',unit_sources,[]),('MIHENUITests',ui_sources,[])]:
 phases=[phase('sources:'+name,'PBXSourcesBuildPhase',sources),put('frameworks:'+name,'PBXFrameworksBuildPhase',buildActionMask=2147483647,files=[],runOnlyForDeploymentPostprocessing=0),phase('resources:'+name,'PBXResourcesBuildPhase',resources)]
 settings=dict(common,PRODUCT_NAME='$(TARGET_NAME)',PRODUCT_BUNDLE_IDENTIFIER={'MIHEN':'com.afaqitrade.mihen','MIHENWidget':'com.afaqitrade.mihen.widget','MIHENActivityMonitor':'com.afaqitrade.mihen.monitor','MIHENTests':'com.afaqitrade.mihen.tests','MIHENUITests':'com.afaqitrade.mihen.uitests'}[name],LD_RUNPATH_SEARCH_PATHS=['$(inherited)','@executable_path/Frameworks'])
 deps=[]
 if name=='MIHEN':
  settings.update({'INFOPLIST_FILE':'MIHEN/Resources/Info.plist','CODE_SIGN_ENTITLEMENTS':'MIHEN/Resources/MIHEN.entitlements','ASSETCATALOG_COMPILER_APPICON_NAME':'AppIcon','GENERATE_INFOPLIST_FILE':'NO','PROVISIONING_PROFILE_SPECIFIER':'$(MIHEN_APP_PROFILE_NAME)'})
  embed=put('embed:widget','PBXBuildFile',fileRef=products['MIHENWidget'],settings={'ATTRIBUTES':['RemoveHeadersOnCopy']})
  phases.append(put('embed:phase','PBXCopyFilesBuildPhase',buildActionMask=2147483647,dstPath='',dstSubfolderSpec=13,files=[embed,put('embed:monitor','PBXBuildFile',fileRef=products['MIHENActivityMonitor'],settings={'ATTRIBUTES':['RemoveHeadersOnCopy']})],name='Embed App Extensions',runOnlyForDeploymentPostprocessing=0))
  deps=[dependency(name,'MIHENWidget'),dependency(name,'MIHENActivityMonitor')]
 elif name=='MIHENActivityMonitor':
  settings.update({'INFOPLIST_FILE':'MIHENActivityMonitor/Info.plist','CODE_SIGN_ENTITLEMENTS':'MIHENActivityMonitor/MIHENActivityMonitor.entitlements','APPLICATION_EXTENSION_API_ONLY':'YES','SKIP_INSTALL':'YES','GENERATE_INFOPLIST_FILE':'NO','PROVISIONING_PROFILE_SPECIFIER':'$(MIHEN_MONITOR_PROFILE_NAME)','LD_RUNPATH_SEARCH_PATHS':['$(inherited)','@executable_path/Frameworks','@executable_path/../../Frameworks']})
 elif name=='MIHENWidget':
  settings.update({'INFOPLIST_FILE':'MIHENWidget/Info.plist','CODE_SIGN_ENTITLEMENTS':'MIHENWidget/MIHENWidget.entitlements','APPLICATION_EXTENSION_API_ONLY':'YES','SKIP_INSTALL':'YES','GENERATE_INFOPLIST_FILE':'NO','PROVISIONING_PROFILE_SPECIFIER':'$(MIHEN_WIDGET_PROFILE_NAME)','LD_RUNPATH_SEARCH_PATHS':['$(inherited)','@executable_path/Frameworks','@executable_path/../../Frameworks']})
 else:
  settings.update({'GENERATE_INFOPLIST_FILE':'YES'})
  deps=[dependency(name,'MIHEN')]
  if name=='MIHENTests':settings.update({'TEST_HOST':'$(BUILT_PRODUCTS_DIR)/MIHEN.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/MIHEN','BUNDLE_LOADER':'$(TEST_HOST)'})
  else:settings['TEST_TARGET_NAME']='MIHEN'
 producttype={'MIHEN':'application','MIHENWidget':'app-extension','MIHENActivityMonitor':'app-extension','MIHENTests':'bundle.unit-test','MIHENUITests':'bundle.ui-testing'}[name]
 put('target:'+name,'PBXNativeTarget',buildConfigurationList=configs(name,settings),buildPhases=phases,buildRules=[],dependencies=deps,name=name,productName=name,productReference=products[name],productType='com.apple.product-type.'+producttype)
put('project','PBXProject',attributes={'BuildIndependentTargetsInParallel':'YES','LastUpgradeCheck':'1620','TargetAttributes':{targets['MIHENTests']:{'TestTargetID':targets['MIHEN']},targets['MIHENUITests']:{'TestTargetID':targets['MIHEN']}}},buildConfigurationList=configs('project',{}),compatibilityVersion='Xcode 14.0',developmentRegion='tr',hasScannedForEncodings=0,knownRegions=['tr','en','Base'],mainGroup=main_group,productRefGroup=product_group,projectDirPath='',projectRoot='',targets=list(targets.values()))
def serialize(v):
 if isinstance(v,dict):return '{\n'+''.join(str(k)+' = '+serialize(val)+';\n' for k,val in v.items())+'}'
 if isinstance(v,list):return '( '+', '.join(serialize(x) for x in v)+' )'
 if isinstance(v,int):return str(v)
 return json.dumps(v,ensure_ascii=False)
project=root/'MIHEN.xcodeproj';project.mkdir(exist_ok=True)
(project/'project.pbxproj').write_text('// !$*UTF8*$!\n'+serialize({'archiveVersion':1,'classes':{},'objectVersion':56,'objects':objects,'rootObject':oid('project')})+'\n')
schemes=project/'xcshareddata/xcschemes';schemes.mkdir(parents=True,exist_ok=True)
def buildref(name):return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{targets[name]}" BuildableName="{name}.{("app" if name=="MIHEN" else "xctest")}" BlueprintName="{name}" ReferencedContainer="container:MIHEN.xcodeproj"/>'
scheme=f'''<?xml version="1.0" encoding="UTF-8"?><Scheme LastUpgradeVersion="1620" version="1.3"><BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{buildref('MIHEN')}</BuildActionEntry></BuildActionEntries></BuildAction><TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">{buildref('MIHENTests')}</TestableReference><TestableReference skipped="NO">{buildref('MIHENUITests')}</TestableReference></Testables></TestAction><LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{buildref('MIHEN')}</BuildableProductRunnable></LaunchAction><ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugServiceExtension="internal"><BuildableProductRunnable runnableDebuggingMode="0">{buildref('MIHEN')}</BuildableProductRunnable></ProfileAction><AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/></Scheme>'''
(schemes/'MIHEN.xcscheme').write_text(scheme)
print(f'Generated {len(objects)} objects; {len(app_sources)} app Swift sources; 5 targets')
