#!/usr/bin/env python3
"""Deterministic Xcode project generation, using only Python's standard library."""
from pathlib import Path
import hashlib
import json
root = Path(__file__).resolve().parents[1]
objects = {}
def uid(value): return hashlib.sha1(value.encode()).hexdigest()[:24].upper()
def add(key, value):
    key = uid(key); objects[key] = value; return key
def arr(values): return '(' + ', '.join(values) + ',)' if values else '()'
def quote(value): return json.dumps(str(value))
def fields(**kwargs): return '{ ' + ' '.join(f'{k} = {v};' for k,v in kwargs.items()) + ' }'
project = uid('project'); target = uid('app'); test_target = uid('test')
app_ref = add('app-product', fields(isa='PBXFileReference', explicitFileType='wrapper.application', path='CineSeeker.app', sourceTree='BUILT_PRODUCTS_DIR'))
test_ref = add('test-product', fields(isa='PBXFileReference', explicitFileType='wrapper.cfbundle', path='CineSeekerTests.xctest', sourceTree='BUILT_PRODUCTS_DIR'))
refs=[]; sources=[]; tests=[]; resources=[]
for path in sorted((root/'CineSeeker').rglob('*.swift')) + sorted((root/'CineSeekerTests').rglob('*.swift')):
    rel=str(path.relative_to(root)); ref=add(rel, fields(isa='PBXFileReference', lastKnownFileType='sourcecode.swift', path=quote(rel), sourceTree='SOURCE_ROOT')); refs.append(ref)
    build=add(rel+'-build', fields(isa='PBXBuildFile', fileRef=ref))
    (tests if 'CineSeekerTests/' in rel else sources).append(build)
for rel, kind in [('CineSeeker/Resources/Assets.xcassets','folder.assetcatalog'),('CineSeeker/Resources/PrivacyInfo.xcprivacy','text.xml')]:
    ref=add(rel, fields(isa='PBXFileReference', lastKnownFileType=kind, path=quote(rel), sourceTree='SOURCE_ROOT')); refs.append(ref)
    resources.append(add(rel+'-build', fields(isa='PBXBuildFile', fileRef=ref)))
config_ref=add('config-file', fields(isa='PBXFileReference', lastKnownFileType='text.xcconfig', path=quote('Config/Defaults.xcconfig'), sourceTree='SOURCE_ROOT')); refs.append(config_ref)
products=add('products', fields(isa='PBXGroup', children=arr([app_ref,test_ref]), name='Products', sourceTree=quote('<group>')))
main=add('group',fields(isa='PBXGroup',children=arr(refs+[products]),sourceTree=quote('<group>')))
def phase(name, isa, files): return add(name,fields(isa=isa,buildActionMask='2147483647',files=arr(files),runOnlyForDeploymentPostprocessing='0'))
app_phases=[phase('app-sources','PBXSourcesBuildPhase',sources),phase('app-frameworks','PBXFrameworksBuildPhase',[]),phase('app-resources','PBXResourcesBuildPhase',resources)]
test_phases=[phase('test-sources','PBXSourcesBuildPhase',tests),phase('test-frameworks','PBXFrameworksBuildPhase',[])]
def configs(prefix, common):
    ids=[]
    for name in ['Debug','Release']:
        settings=common.copy()
        settings.update({'SWIFT_OPTIMIZATION_LEVEL':quote('-Onone' if name=='Debug' else '-O'),'DEBUG_INFORMATION_FORMAT':quote('dwarf' if name=='Debug' else 'dwarf-with-dsym')})
        if name=='Debug': settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS']=quote('DEBUG $(inherited)'); settings['ENABLE_TESTABILITY']='YES'
        ids.append(add(prefix+name, fields(isa='XCBuildConfiguration',baseConfigurationReference=config_ref,buildSettings=fields(**settings),name=name)))
    return add(prefix+'configs',fields(isa='XCConfigurationList',buildConfigurations=arr(ids),defaultConfigurationIsVisible='0',defaultConfigurationName='Release'))
project_configs=configs('project-',dict(SWIFT_VERSION='6.0',IPHONEOS_DEPLOYMENT_TARGET='17.0',SDKROOT='iphoneos',CLANG_ENABLE_MODULES='YES',CLANG_ENABLE_OBJC_ARC='YES',SWIFT_STRICT_CONCURRENCY='complete',ENABLE_USER_SCRIPT_SANDBOXING='YES'))
app_configs=configs('app-',dict(PRODUCT_NAME=quote('$(TARGET_NAME)'),INFOPLIST_FILE=quote('CineSeeker/Resources/Info.plist'),CURRENT_PROJECT_VERSION='1',MARKETING_VERSION='1.0.0',VERSIONING_SYSTEM=quote('apple-generic'),CODE_SIGN_STYLE='Automatic',TARGETED_DEVICE_FAMILY=quote('1,2'),ASSETCATALOG_COMPILER_APPICON_NAME='AppIcon',SUPPORTED_PLATFORMS=quote('iphoneos iphonesimulator'),SUPPORTS_MACCATALYST='NO',LD_RUNPATH_SEARCH_PATHS=quote('$(inherited) @executable_path/Frameworks')))
test_configs=configs('test-',dict(PRODUCT_NAME=quote('$(TARGET_NAME)'),PRODUCT_BUNDLE_IDENTIFIER='com.projectcagla.cineseeker.tests',GENERATE_INFOPLIST_FILE='YES',TEST_HOST=quote('$(BUILT_PRODUCTS_DIR)/CineSeeker.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/CineSeeker'),BUNDLE_LOADER=quote('$(TEST_HOST)'),CODE_SIGN_STYLE='Automatic',TARGETED_DEVICE_FAMILY=quote('1,2')))
proxy=add('test-proxy',fields(isa='PBXContainerItemProxy',containerPortal=project,proxyType='1',remoteGlobalIDString=target,remoteInfo='CineSeeker'))
dep=add('test-dep',fields(isa='PBXTargetDependency',target=target,targetProxy=proxy))
objects[target]=fields(isa='PBXNativeTarget',buildConfigurationList=app_configs,buildPhases=arr(app_phases),buildRules='()',dependencies='()',name='CineSeeker',productName='CineSeeker',productReference=app_ref,productType=quote('com.apple.product-type.application'))
objects[test_target]=fields(isa='PBXNativeTarget',buildConfigurationList=test_configs,buildPhases=arr(test_phases),buildRules='()',dependencies=arr([dep]),name='CineSeekerTests',productName='CineSeekerTests',productReference=test_ref,productType=quote('com.apple.product-type.bundle.unit-test'))
objects[project]=fields(isa='PBXProject',attributes=fields(BuildIndependentTargetsInParallel='YES',LastUpgradeCheck='1600'),buildConfigurationList=project_configs,compatibilityVersion=quote('Xcode 15.0'),developmentRegion='tr',hasScannedForEncodings='0',knownRegions=arr(['tr','en','Base']),mainGroup=main,productRefGroup=products,projectDirPath='""',projectRoot='""',targets=arr([target,test_target]))
out=root/'CineSeeker.xcodeproj'; out.mkdir(exist_ok=True)
(out/'project.pbxproj').write_text('// !$*UTF8*$!\n{ archiveVersion = 1; classes = {}; objectVersion = 60; objects = {\n'+'\n'.join(f'{key} = {value};' for key,value in objects.items())+f'\n}}; rootObject = {project}; }}\n')
scheme=out/'xcshareddata/xcschemes'; scheme.mkdir(parents=True,exist_ok=True)
def ref(id,name,product): return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{id}" BuildableName="{product}" BlueprintName="{name}" ReferencedContainer="container:CineSeeker.xcodeproj"/>'
app=ref(target,'CineSeeker','CineSeeker.app'); test=ref(test_target,'CineSeekerTests','CineSeekerTests.xctest')
(scheme/'CineSeeker.xcscheme').write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1600" version="1.3"><BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{app}</BuildActionEntry></BuildActionEntries></BuildAction><TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">{test}</TestableReference></Testables></TestAction><LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{app}</BuildableProductRunnable></LaunchAction><ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{app}</BuildableProductRunnable></ProfileAction><AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/></Scheme>''')
print('Generated CineSeeker.xcodeproj')
