/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2011 Viktor Lidholt
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "AppDelegate.h"
#import "CocosScene.h"
#import "SceneGraph.h"
#import "CCBGLView.h"
#import "NSFlippedView.h"
#import "CCBGlobals.h"
#import "cocos2d.h"
#import "CCBWriterInternal.h"
#import "CCBReaderInternal.h"
#import "CCBReaderInternalV1.h"
#import "CCBDocument.h"
#import "NewDocWindowController.h"
#import "CCBSpriteSheetParser.h"
#import "CCBUtil.h"
#import "StageSizeWindow.h"
#import "GuideGridSizeWindow.h"
#import "ResolutionSettingsWindow.h"
#import "PlugInManager.h"
#import "InspectorPosition.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "PlugInExport.h"
#import "TexturePropertySetter.h"
#import "PositionPropertySetter.h"
#import "ResourceManager.h"
#import "GuidesLayer.h"
#import "RulersLayer.h"
#import "NSString+RelativePath.h"
#import "CCBTransparentWindow.h"
#import "CCBTransparentView.h"
#import "NotesLayer.h"
#import "ResolutionSetting.h"
#import "ProjectSettingsWindowController.h"
#import "ProjectSettings.h"
#import "ResourceManagerOutlineHandler.h"
#import "ResourceManagerOutlineView.h"
#import "SavePanelLimiter.h"
#import "CCBWarnings.h"
#import "TaskStatusWindow.h"
#import "SequencerHandler.h"
#import "MainWindow.h"
#import "CCNode+NodeInfo.h"
#import "SequencerNodeProperty.h"
#import "SequencerSequence.h"
#import "SequencerSettingsWindow.h"
#import "SequencerDurationWindow.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "SequencerKeyframeEasingWindow.h"
#import "SequencerUtil.h"
#import "SequencerStretchWindow.h"
#import "SequencerSoundChannel.h"
#import "SequencerCallbackChannel.h"
#import "SequencerJoints.h"
#import "SoundFileImageController.h"
#import "CustomPropSettingsWindow.h"
#import "CustomPropSetting.h"
#import "MainToolbarDelegate.h"
#import "InspectorSeparator.h"
#import "HelpWindow.h"
#import "APIDocsWindow.h"
#import "NodeGraphPropertySetter.h"
#import "CCBSplitHorizontalView.h"
#import "SpriteSheetSettingsWindow.h"
#import "AboutWindow.h"
#import "CCBFileUtil.h"
#import "ResourceManagerUtil.h"
#import "SMTabBar.h"
#import "SMTabBarItem.h"
#import "ResourceManagerTilelessEditorManager.h"
#import "CCBImageBrowserView.h"
#import "PlugInNodeViewHandler.h"
#import "PropertyInspectorTemplateHandler.h"
#import "LocalizationEditorHandler.h"
#import "PhysicsHandler.h"
#import "CCBProjectCreator.h"
#import "CCTextureCache.h"
#import "CCLabelBMFont_Private.h"
#import "WarningTableViewHandler.h"
#import "CCNode+NodeInfo.h"
#import "CCNode_Private.h"
#import "UsageManager.h"
#import <ExceptionHandling/NSExceptionHandler.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <MacTypes.h>
#import "PlugInNodeCollectionView.h"
#import "SBErrors.h"
#import "NSArray+Query.h"
#import "Cocos2dUpdater.h"
#import "OALSimpleAudio.h"
#import "SBUserDefaultsKeys.h"
#import "MiscConstants.h"
#import "FeatureToggle.h"
#import "AnimationPlaybackManager.h"
#import "NotificationNames.h"
#import "MailingListWindow.h"
#import "ResourceTypes.h"
#import "RMDirectory.h"
#import "RMResource.h"
#import "PackageImporter.h"
#import "PackageCreator.h"
#import "ResourceCommandController.h"
#import "ProjectMigrator.h"
#import "ProjectSettings+Convenience.h"
#import "CCBDocumentDataCreator.h"
#import "CCBPublisherCacheCleaner.h"
#import "CCBPublisherController.h"
#import "ResourceManager+Publishing.h"
#import "SBUpdater.h"
#import "CCNode+NodeInfo.h"
#import "PreviewContainerViewController.h"
#import "InspectorController.h"
#import "SBOpenPathsController.h"
#import "LightingHandler.h"

static const int CCNODE_INDEX_LAST = -1;

@interface AppDelegate()

@property (nonatomic, strong) CCBPublisherController *publisherController;
@property (nonatomic, strong) ResourceCommandController *resourceCommandController;

@end


@implementation AppDelegate

@synthesize window;
@synthesize projectSettings;
@synthesize currentDocument;
@synthesize cocosView;
@synthesize canEditContentSize;
@synthesize canEditCustomClass;
@synthesize hasOpenedDocument;
@synthesize defaultCanvasSize;
@synthesize projectOutlineHandler;
@synthesize showExtras;
@synthesize showGuides;
@synthesize showGuideGrid;
@synthesize showStickyNotes;
@synthesize snapToggle;
@synthesize snapGrid;
@synthesize snapToGuides;
@synthesize snapNode;
@synthesize guiView;
@synthesize guiWindow;
@synthesize menuContextKeyframe;
@synthesize menuContextKeyframeInterpol;
@synthesize menuContextKeyframeNoselection;
@synthesize outlineProject;
@synthesize errorDescription;
@synthesize selectedNodes;
@synthesize loadedSelectedNodes;
@synthesize panelVisibilityControl;
@synthesize localizationEditorHandler;
@synthesize physicsHandler;
@synthesize itemTabView;
@dynamic selectedNodeCanHavePhysics;
@synthesize playingBack;
@dynamic	showJoints;
@synthesize lightingHandler;

static AppDelegate* sharedAppDelegate;

#pragma mark Setup functions

+ (AppDelegate*) appDelegate
{
    return sharedAppDelegate;
}

//This function replaces the current CCNode visit with "customVisit" to ensure that 'hidden' flagged nodes are invisible.
//However it then proceeds to call the real '[CCNode visit]' (now renamed oldVisit).
void ApplyCustomNodeVisitSwizzle()
{
	
    Method origMethod = class_getInstanceMethod([CCNode class], @selector(visit:parentTransform:));
    Method newMethod = class_getInstanceMethod([CCNode class], @selector(customVisit:parentTransform:));
    
    IMP origImp = method_getImplementation(origMethod);
    IMP newImp = method_getImplementation(newMethod);
    
    class_replaceMethod([CCNode class], @selector(visit:parentTransform:), newImp, method_getTypeEncoding(newMethod));
    class_addMethod([CCNode class], @selector(oldVisit:parentTransform:), origImp, method_getTypeEncoding(origMethod));
}

- (void) setupCocos2d
{
    ApplyCustomNodeVisitSwizzle();
    
    // Insert code here to initialize your application
    CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];

    NSAssert(cocosView, @"cocosView is nil");
    [director setView:cocosView];
    [cocosView setWantsBestResolutionOpenGLSurface:YES];
    [[CCFileUtils sharedFileUtils] buildSearchResolutionsOrder];
	
	[director setDisplayStats:NO];
	[director setProjection:CCDirectorProjection2D];    
    
    _baseContentScaleFactor = director.deviceContentScaleFactor;
    
    [self updatePositionScaleFactor];
    
    CGSize realSize = CGSizeMake(cocosView.frame.size.width * _baseContentScaleFactor, cocosView.frame.size.height * _baseContentScaleFactor);
    
    [director reshapeProjection:realSize];
    
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_NoScale];
	
	// Enable "moving" mouse event. Default no.
	//[window setAcceptsMouseMovedEvents:YES];
	
	[director runWithScene:[CocosScene sceneWithAppDelegate:self]];
	
	NSAssert( [NSThread currentThread] == [[CCDirector sharedDirector] runningThread],
			 @"cocos2d should run on the Main Thread. Compile SpriteBuilder with CC_DIRECTOR_MAC_THREAD=2");
}

- (void) updateDerivedViewScaleFactor {
    CCDirectorMac *director     = (CCDirectorMac*) [CCDirector sharedDirector];
    self.derivedViewScaleFactor = director.contentScaleFactor / director.deviceContentScaleFactor;
}

- (void) setupSequenceHandler
{
    sequenceHandler = [[SequencerHandler alloc] initWithOutlineView:outlineHierarchy];
    sequenceHandler.scrubberSelectionView = scrubberSelectionView;
    sequenceHandler.timeDisplay = timeDisplay;
    sequenceHandler.timeScaleSlider = timeScaleSlider;
    sequenceHandler.scroller = timelineScroller;
    sequenceHandler.scrollView = sequenceScrollView;
    sequenceHandler.lightVisibilityDelegate = self.lightingHandler;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSoundImages:) name:kSoundFileImageLoaded object:nil];
    
    [self updateTimelineMenu];
    [sequenceHandler updateScaleSlider];
}

-(void)updateSoundImages:(NSNotification*)notice
{
    [outlineHierarchy reloadData];
}

- (void) setupTabBar
{
    // Create tabView
    tabView = [[NSTabView alloc] initWithFrame:NSMakeRect(0, 0, 500, 30)];
    [tabBar setTabView:tabView];
    [tabView setDelegate:tabBar];
    [tabBar setDelegate:self];
    
    // Settings for tabBar
    [tabBar setShowAddTabButton:NO];
    [tabBar setSizeCellsToFit:YES];
    [tabBar setUseOverflowMenu:YES];
    [tabBar setHideForSingleTab:NO];
    [tabBar setAllowsResizing:YES];
    [tabBar setAlwaysShowActiveTab:YES];
    [tabBar setAllowsScrubbing:YES];
    [tabBar setCanCloseOnlyTab:YES];
    
    [window setShowsToolbarButton:NO];
}

- (void) setupPlugInNodeView
{
    plugInNodeViewHandler  = [[PlugInNodeViewHandler alloc] initWithCollectionView:plugInNodeCollectionView];
}

- (void) setupProjectViewTabBar
{
    NSMutableArray* items = [NSMutableArray array];
    
    NSImage* imgFolder = [NSImage imageNamed:@"inspector-folder"];
    [imgFolder setTemplate:YES];
    SMTabBarItem* itemFolder = [[SMTabBarItem alloc] initWithImage:imgFolder tag:0];
    itemFolder.toolTip = @"File View";
    itemFolder.keyEquivalent = @"";
    [items addObject:itemFolder];
    
    NSImage* imgObjs = [NSImage imageNamed:@"inspector-objects"];
    [imgObjs setTemplate:YES];
    SMTabBarItem* itemObjs = [[SMTabBarItem alloc] initWithImage:imgObjs tag:1];
    itemObjs.toolTip = @"Tileless Editor View";
    itemObjs.keyEquivalent = @"";
    [items addObject:itemObjs];
    
    NSImage* imgNodes = [NSImage imageNamed:@"inspector-nodes"];
    [imgNodes setTemplate:YES];
    SMTabBarItem* itemNodes = [[SMTabBarItem alloc] initWithImage:imgNodes tag:2];
    itemNodes.toolTip = @"Node Library View";
    itemNodes.keyEquivalent = @"";
    [items addObject:itemNodes];
    
    NSImage* imgWarnings = [NSImage imageNamed:@"inspector-warning"];
    [imgWarnings setTemplate:YES];
    SMTabBarItem* itemWarnings = [[SMTabBarItem alloc] initWithImage:imgWarnings tag:3];
    itemWarnings.toolTip = @"Warnings view";
    itemWarnings.keyEquivalent = @"";
    [items addObject:itemWarnings];

    projectViewTabs.items = items;
    projectViewTabs.delegate = self;
}

typedef enum
{
	eItemViewTabType_Properties,
	eItemViewTabType_CodeConnections,
	eItemViewTabType_Physics,
	eItemViewTabType_Template
	
} eItemViewTabType;

- (void) setupItemViewTabBar
{
    NSMutableArray* items = [NSMutableArray array];
    
    NSImage* imgProps = [NSImage imageNamed:@"inspector-props"];
    [imgProps setTemplate:YES];
    SMTabBarItem* itemProps = [[SMTabBarItem alloc] initWithImage:imgProps tag:0];
    itemProps.toolTip = @"Item Properties";
    itemProps.keyEquivalent = @"";
	itemProps.tag = eItemViewTabType_Properties;
    [items addObject:itemProps];
    
    NSImage* imgCode = [NSImage imageNamed:@"inspector-codeconnections"];
    [imgCode setTemplate:YES];
    SMTabBarItem* itemCode = [[SMTabBarItem alloc] initWithImage:imgCode tag:0];
    itemCode.toolTip = @"Item Code Connections";
    itemCode.keyEquivalent = @"";
	itemCode.tag = eItemViewTabType_CodeConnections;
    [items addObject:itemCode];
    
    NSImage* imgPhysics = [NSImage imageNamed:@"inspector-physics"];
    [imgPhysics setTemplate:YES];
    SMTabBarItem* itemPhysics = [[SMTabBarItem alloc] initWithImage:imgPhysics tag:0];
    itemPhysics.toolTip = @"Item Physics";
    itemPhysics.keyEquivalent = @"";
	itemPhysics.tag = eItemViewTabType_Physics;
    [items addObject:itemPhysics];
    
    NSImage* imgTemplate = [NSImage imageNamed:@"inspector-template"];
    [imgTemplate setTemplate:YES];
    SMTabBarItem* itemTemplate = [[SMTabBarItem alloc] initWithImage:imgTemplate tag:0];
    itemTemplate.toolTip = @"Item Templates";
    itemTemplate.keyEquivalent = @"";
	itemTemplate.tag = eItemViewTabType_Template;
    [items addObject:itemTemplate];
    
    itemViewTabs.items = items;
    itemViewTabs.delegate = self;
}

- (void)tabBar:(SMTabBar *)tb didSelectItem:(SMTabBarItem *)item
{
    if (tb == projectViewTabs)
    {
        [projectTabView selectTabViewItemAtIndex:[projectViewTabs.items indexOfObject:item]];
    }
    else if (tb == itemViewTabs)
    {
        [itemTabView selectTabViewItemAtIndex:[itemViewTabs.items indexOfObject:item]];
    }
}

- (void) updateSmallTabBarsEnabled
{
    // Set enable for open project
    BOOL allEnable = (projectSettings != NULL);
    
    if (!allEnable)
    {
        // If project isn't open, set selected tab to the first one
        [projectViewTabs setSelectedItem:[projectViewTabs.items objectAtIndex:0]];
        [projectTabView selectTabViewItemAtIndex:0];
        
        [itemViewTabs setSelectedItem:[itemViewTabs.items objectAtIndex:0]];
        [itemTabView selectTabViewItemAtIndex:0];
    }
    
    // Update enable for project
    for (SMTabBarItem* item in projectViewTabs.items)
    {
        item.enabled = allEnable;
    }
    
    // Update enable depending on if object is selected
    BOOL itemEnable = (self.selectedNode != NULL);
	BOOL physicsEnabled = (!self.selectedNode.plugIn.isJoint)  && (![self.selectedNode.plugIn.nodeClassName isEqualToString:@"CCBFile"]);
	
    for (SMTabBarItem* item in itemViewTabs.items)
    {
		if(item.tag == eItemViewTabType_Physics && !physicsEnabled)
		{
			item.enabled = NO;
			continue;
		}
		
        item.enabled = allEnable && itemEnable;
    }
    
    BOOL templateEnable = (itemEnable && self.selectedNode.plugIn.supportsTemplates);
    SMTabBarItem* templateItem = [itemViewTabs.items objectAtIndex:3];
    templateItem.enabled = templateEnable;

    if (!templateEnable && [itemViewTabs selectedItem] == templateItem)
    {
        // If template isn't available select first tab instead
        [itemViewTabs setSelectedItem:[itemViewTabs.items objectAtIndex:0]];
        [itemTabView selectTabViewItemAtIndex:0];
    }
	
	// physics tab forcibly disabled for Sprite Kit projects as there is no pyhsics editing support (yet)
	if (projectSettings.engine == CCBTargetEngineSpriteKit)
	{
		if (itemViewTabs.items.count > 2)
		{
			SMTabBarItem* item = [itemViewTabs.items objectAtIndex:2];
			item.enabled = NO;
			//NSLog(@"Sprite Kit disabled tab item: %@", item);
		}
	}
}

- (void) setupProjectTilelessEditor
{
    tilelessEditorManager = [[ResourceManagerTilelessEditorManager alloc] initWithImageBrowser:projectImageBrowserView];
    [tilelessEditorTableFilterView setDataSource:tilelessEditorManager];
    [tilelessEditorTableFilterView setDelegate:tilelessEditorManager];
    [tilelessEditorTableFilterView setBackgroundColor:[NSColor colorWithCalibratedRed:0.93 green:0.93 blue:0.93 alpha:2]];
    [tilelessEditorSplitView setDelegate:tilelessEditorManager];
}

- (void) setupResourceManager
{
    NSColor * color = [NSColor colorWithCalibratedRed:0.0f green:0.50f blue:0.50f alpha:1.0f];
    
    color = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];

    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    NSColor * color2 = [NSColor colorWithDeviceRed:r green:g blue:b alpha:a];
    NSColor * calibratedColor = [color2 colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

    NSLog(@"R:%f G:%f B:%f A:%f",calibratedColor.redComponent, calibratedColor.greenComponent, calibratedColor.blueComponent, calibratedColor.alphaComponent);
    
    // Load resource manager
	[ResourceManager sharedManager];
    

    // Setup project display
    projectOutlineHandler = [[ResourceManagerOutlineHandler alloc] initWithOutlineView:outlineProject
                                                                               resType:kCCBResTypeNone
                                                                     previewController:_previewContainerViewController];
    projectOutlineHandler.projectSettings = projectSettings;
    resourceManagerSplitView.delegate = _previewContainerViewController;

    //Setup warnings outline
    warningHandler = [[WarningTableViewHandler alloc] init];
    
    self.warningTableView.delegate = warningHandler;
    self.warningTableView.target = warningHandler;
    self.warningTableView.dataSource = warningHandler;
    [self updateWarningsOutline];
}

- (void) setupGUIWindow
{
    NSRect frame = cocosView.frame;
    
    frame.origin = [cocosView convertPoint:NSZeroPoint toView:NULL];
    frame.origin.x += self.window.frame.origin.x;
    frame.origin.y += self.window.frame.origin.y;
    
    guiWindow = [[CCBTransparentWindow alloc] initWithContentRect:frame];
    
    guiView = [[CCBTransparentView alloc] initWithFrame:cocosView.frame];
    [guiWindow setContentView:guiView];
    guiWindow.delegate = self;
    
    [window addChildWindow:guiWindow ordered:NSWindowAbove];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#ifndef TESTING
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"138b7cc7454016e05dbbc512f38082b7" delegate:self];
    
    [[BITHockeyManager sharedHockeyManager] startManager];
#endif

    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"ApplePersistenceIgnoreState"];

    [self registerUserDefaults];

    [self registerNotificationObservers];

    // Disable experimental features
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"EnableSpriteKit"] boolValue])
    {
        [[_menuItemExperimentalSpriteKitProject menu] removeItem:_menuItemExperimentalSpriteKitProject];
    }

    [[UsageManager sharedManager] registerUsage];
    
    // Initialize Audio
    //[OALSimpleAudio sharedInstance];

    [self setupFeatureToggle];
    
    selectedNodes = [[NSMutableArray alloc] init];
    loadedSelectedNodes = [[NSMutableArray alloc] init];
    
    sharedAppDelegate = self;
    
    [[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask: NSLogUncaughtExceptionMask | NSLogUncaughtSystemExceptionMask | NSLogUncaughtRuntimeErrorMask];
    
    // iOS
    defaultCanvasSizes[kCCBCanvasSizeIPhoneLandscape] = CGSizeMake(480, 320);
    defaultCanvasSizes[kCCBCanvasSizeIPhonePortrait] = CGSizeMake(320, 480);
    defaultCanvasSizes[kCCBCanvasSizeIPhone5Landscape] = CGSizeMake(568, 320);
    defaultCanvasSizes[kCCBCanvasSizeIPhone5Portrait] = CGSizeMake(320, 568);
    defaultCanvasSizes[kCCBCanvasSizeIPadLandscape] = CGSizeMake(512, 384);
    defaultCanvasSizes[kCCBCanvasSizeIPadPortrait] = CGSizeMake(384, 512);
    
    // Fixed
    defaultCanvasSizes[kCCBCanvasSizeFixedLandscape] = CGSizeMake(568, 384);
    defaultCanvasSizes[kCCBCanvasSizeFixedPortrait] = CGSizeMake(384, 568);
    
    // Android
    defaultCanvasSizes[kCCBCanvasSizeAndroidXSmallLandscape] = CGSizeMake(320, 240);
    defaultCanvasSizes[kCCBCanvasSizeAndroidXSmallPortrait] = CGSizeMake(240, 320);
    defaultCanvasSizes[kCCBCanvasSizeAndroidSmallLandscape] = CGSizeMake(480, 340);
    defaultCanvasSizes[kCCBCanvasSizeAndroidSmallPortrait] = CGSizeMake(340, 480);
    defaultCanvasSizes[kCCBCanvasSizeAndroidMediumLandscape] = CGSizeMake(800, 480);
    defaultCanvasSizes[kCCBCanvasSizeAndroidMediumPortrait] = CGSizeMake(480, 800);
    
    [window setDelegate:self];

    [self setupTabBar];


    [self setupCocos2d];
    [self setupSequenceHandler];
    animationPlaybackManager.sequencerHandler = sequenceHandler;

    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    
    CocosScene* cs = [CocosScene cocosScene];
    [cs setStageBorder:0];
    [self updateCanvasBorderMenu];
    //[self updateJSControlledMenu];
    //[self updateDefaultBrowser];
    // Load plug-ins
    [[PlugInManager sharedManager] loadPlugIns];
    
    [self setupPlugInNodeView];
    [self setupProjectViewTabBar];
    [self setupItemViewTabBar];
    [self updateSmallTabBarsEnabled];
    [self setupResourceManager];
    [self setupGUIWindow];
    [self setupProjectTilelessEditor];
    [self setupExtras];
    [self setupResourceCommandController];
	[self setupSparkleGui];
	
    [window restorePreviousOpenedPanels];

    [self.window makeKeyWindow];
    
    // Install default templates
    [_propertyInspectorTemplateHandler installDefaultTemplatesReplace:NO];
    [_propertyInspectorTemplateHandler loadTemplateLibrary];

    [InspectorController setSingleton:_inspectorController];
    [self setupInspectorController];
    [_inspectorController updateInspectorFromSelection];

	_applicationLaunchComplete = YES;
    
    if (YOSEMITE_UI)
    {
        [loopButton setBezelStyle:NSTexturedRoundedBezelStyle];
    }
    

#ifdef TESTING
	return;
#endif
	

    // Open registration window
    BOOL alreadyRegistered = (BOOL)([[NSUserDefaults standardUserDefaults] objectForKey:kSbRegisteredEmail]);

    if(!alreadyRegistered && ![self openRegistration])
	{
		[[NSApplication sharedApplication] terminate:self];
	}

    if (delayOpenFiles)
    {
        [self openFiles:delayOpenFiles];
        delayOpenFiles = nil;
    }
    else
    {
        #ifndef TESTING
        [self openLastOpenProject];
        #endif
    }
    
    // Check for first run
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"completedFirstRun"] boolValue])
    {
        //[self showHelp:self];
        
        // First run completed
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"completedFirstRun"];
    }

    [self toggleFeatures];

    [_openPathsController populateOpenPathsMenuItems];
}

- (void)setupInspectorController
{
    _inspectorController.appDelegate = self;
    _inspectorController.cocosScene = [CocosScene cocosScene];
    _inspectorController.sequenceHandler = [SequencerHandler sharedHandler];

    [_inspectorController setupInspectorPane];
}

- (void)setupResourceCommandController
{
    _resourceCommandController = [[ResourceCommandController alloc] init];
    _resourceCommandController.resourceManagerOutlineView = outlineProject;
    _resourceCommandController.window = window;
    _resourceCommandController.resourceManager = [ResourceManager sharedManager];
    _resourceCommandController.publishDelegate = self;

    outlineProject.actionTarget = _resourceCommandController;
}

- (void)toggleFeatures
{
    // Empty at the moment, but if there is something you'd like to toggle in the scope of the AppDelegate, add it here
}

- (void)setupFeatureToggle
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Features" ofType:@"plist"];
    NSDictionary *features = [NSDictionary dictionaryWithContentsOfFile:path];
    [[FeatureToggle sharedFeatures] loadFeaturesWithDictionary:features];
}

- (void)registerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEverythingAfterSettingsChanged) name:RESOURCE_PATHS_CHANGED object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadResources) name:RESOURCES_CHANGED object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removedDocumentWithPath:) name:RESOURCE_PATH_REMOVED object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deselectAll) name:ANIMATION_PLAYBACK_WILL_START object:nil];
}

- (void)registerUserDefaults
{
    NSDictionary *defaults = @{
            LAST_VISIT_LEFT_PANEL_VISIBLE : @(1),
            LAST_VISIT_BOTTOM_PANEL_VISIBLE : @(1),
            LAST_VISIT_RIGHT_PANEL_VISIBLE : @(1)};

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)openLastOpenProject
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *filePath = [defaults valueForKey:LAST_OPENED_PROJECT_PATH];
    if (filePath)
    {
        [self openProject:filePath];
    }
}

#pragma mark Notifications to user

- (void) modalDialogTitle: (NSString*)title message:(NSString*)msg
{
    NSAlert* alert = [NSAlert alertWithMessageText:title defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"%@",msg];
	[alert runModal];
}

- (void) modalDialogTitle: (NSString*)title message:(NSString*)msg disableKey:(NSString*)key
{
	if(![self showHelpDialog:key])
	{
		return;
	}
	
	NSAlert* alert = [NSAlert alertWithMessageText:title defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"%@",msg];
	
	[alert setShowsSuppressionButton:YES];
	[alert runModal];
	
	if ([[alert suppressionButton] state] == NSOnState) {
        // Suppress this alert from now on.
		[self disableHelpDialog:key];
    }
}

- (void)modalStatusWindowStartWithTitle:(NSString *)title isIndeterminate:(BOOL)isIndeterminate onCancelBlock:(OnCancelBlock)onCancelBlock
{
    if (!modalTaskStatusWindow)
    {
        modalTaskStatusWindow = [[TaskStatusWindow alloc] initWithWindowNibName:@"TaskStatusWindow"];
    }

    modalTaskStatusWindow.indeterminate = isIndeterminate;
    modalTaskStatusWindow.onCancelBlock = onCancelBlock;
    modalTaskStatusWindow.window.title = title;
    [modalTaskStatusWindow.window center];
    [modalTaskStatusWindow.window makeKeyAndOrderFront:self];

    [[NSApplication sharedApplication] runModalForWindow:modalTaskStatusWindow.window];
}

- (void) modalStatusWindowFinish
{
    modalTaskStatusWindow.indeterminate = YES;
    modalTaskStatusWindow.onCancelBlock = nil;
    [[NSApplication sharedApplication] stopModal];
    [modalTaskStatusWindow.window orderOut:self];
    modalTaskStatusWindow = nil;
}

- (void) modalStatusWindowUpdateStatusText:(NSString*) text
{
    [modalTaskStatusWindow updateStatusText:text];
}


#pragma mark Handling the gui layer

- (void) resizeGUIWindow:(NSSize)size
{
    NSRect frame = guiView.frame;
    frame.size = size;
    guiView.frame = NSMakeRect(0, 0, frame.size.width, frame.size.height);
    
    frame = cocosView.frame;
    frame.origin = [cocosView convertPoint:NSZeroPoint toView:NULL];
    frame.origin.x += self.window.frame.origin.x;
    frame.origin.y += self.window.frame.origin.y;
    
    [guiWindow setFrameOrigin:frame.origin];
    
    
    frame = guiWindow.frame;
    frame.size = size;
    [guiWindow setFrame:frame display:YES];
}

#pragma mark Handling the tab bar

- (void) addTab:(CCBDocument*)doc
{
    NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:doc];
	[newItem setLabel:[doc formattedName]];
	[tabView addTabViewItem:newItem];
    [tabView selectTabViewItem:newItem]; // this is optional, but expected behavior
}

- (void)tabView:(NSTabView*)tv didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [self switchToDocument:[tabViewItem identifier]];
}

- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ([[aTabView tabViewItems] count] == 0)
    {
        [self closeLastDocument];
    }
    
    [self updateDirtyMark];
}


- (BOOL)tabView:(NSTabView *)aTabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
    CCBDocument* doc = [tabViewItem identifier];
    
    if (doc.isDirty)
    {
        NSAlert* alert = [NSAlert alertWithMessageText:[NSString stringWithFormat: @"Do you want to save the changes you made in the document “%@”?", [doc.filePath lastPathComponent]] defaultButton:@"Save" alternateButton:@"Cancel" otherButton:@"Don’t Save" informativeTextWithFormat:@"Your changes will be lost if you don’t save them."];
        NSInteger result = [alert runModal];
        
        if (result == NSAlertDefaultReturn)
        {
            [self saveDocument:self];
            return YES;
        }
        else if (result == NSAlertAlternateReturn)
        {
            return NO;
        }
        else if (result == NSAlertOtherReturn)
        {
            return YES;
        }
    }
    return YES;
}

- (BOOL)tabView:(NSTabView *)aTabView shouldDragTabViewItem:(NSTabViewItem *)tabViewItem fromTabBar:(PSMTabBarControl *)tabBarControl
{
    return YES;
}

#pragma mark Handling selections

- (BOOL) nodeHasCCBFileAncestor:(CCNode*)node
{
    while (node.parent != NULL)
    {
        if ([NSStringFromClass(node.parent.class) isEqualToString:@"CCBPCCBFile"])
        {
            return YES;
        }
        node = node.parent;
    }
    return NO;
}

- (void) setSelectedNodes:(NSArray*) selection
{
	
	//Ensure that the selected joint is on top.
	CCBPhysicsJoint* selectedJoint = [selection findFirst:^BOOL(CCNode * node, int idx) {
		return node.plugIn.isJoint;
	}];
	
	if(selectedJoint)
	{
		[[SceneGraph instance].joints.all forEach:^(CCNode * joint, int idx) {
			joint.zOrder = (joint == selectedJoint) ? 1 : 0;
		}];
		
		selection = [NSArray arrayWithObject:selectedJoint];
	}
	
	

	
    [self willChangeValueForKey:@"selectedNode"];
    [self willChangeValueForKey:@"selectedNodes"];
    [physicsHandler willChangeSelection];
    
    // Close the color picker
    [[NSColorPanel sharedColorPanel] close];
    
    if([[self window] firstResponder] != sequenceHandler.outlineHierarchy)
    {
        // Finish editing inspector
        if (![[self window] makeFirstResponder:[self window]])
        {
            return;
        }
    }
    
    
    // Remove any nodes that are part of sub ccb-files OR any nodes that are Locked.
    NSMutableArray* mutableSelection = [NSMutableArray arrayWithArray: selection];
    for (int i = mutableSelection.count -1; i >= 0; i--)
    {
        CCNode* node = [mutableSelection objectAtIndex:i];
        if ([self nodeHasCCBFileAncestor:node])
        {
            [mutableSelection removeObjectAtIndex:i];
        }
    }
    
    // Update selection
    [selectedNodes removeAllObjects];
    if (mutableSelection && mutableSelection.count > 0)
    {
        [selectedNodes addObjectsFromArray:mutableSelection];
        
        // Make sure all nodes have the same parent
        CCNode* lastNode = [selectedNodes objectAtIndex:selectedNodes.count-1];
        CCNode* parent = lastNode.parent;
        
        for (int i = selectedNodes.count -1; i >= 0; i--)
        {
            CCNode* node = [selectedNodes objectAtIndex:i];
            
            if (node.parent != parent)
            {
                [selectedNodes removeObjectAtIndex:i];
            }
        }
    }
    
    [sequenceHandler updateOutlineViewSelection];
    
    // Handle undo/redo
    if (currentDocument) currentDocument.lastEditedProperty = NULL;
    
    [self updateSmallTabBarsEnabled];
    [_propertyInspectorTemplateHandler updateTemplates];
    
    [self didChangeValueForKey:@"selectedNode"];
    [self didChangeValueForKey:@"selectedNodes"];
    
    physicsHandler.selectedNodePhysicsBody = self.selectedNode.nodePhysicsBody;
    [physicsHandler didChangeSelection];

    [animationPlaybackManager stop];
}

- (CCNode*) selectedNode
{
    if (selectedNodes.count == 1)
    {
        return [selectedNodes objectAtIndex:0];
    }
    else
    {
        return NULL;
    }
}

- (void)deselectAll
{
    self.selectedNodes = nil;
}

-(BOOL)selectedNodeCanHavePhysics
{
    if(!self.selectedNode)
        return NO;
    
    if(self.selectedNode.plugIn.isJoint)
        return NO;
    
    return YES;
}

#pragma mark Window Delegate

- (void) windowDidResignMain:(NSNotification *)notification
{
    if (notification.object == self.window)
    {
        CocosScene* cs = [CocosScene cocosScene];
    
        if (![[CCDirector sharedDirector] isPaused])
        {
            [[CCDirector sharedDirector] pause];
            cs.paused = YES;
        }
    }
}

- (void) windowDidBecomeMain:(NSNotification *)notification
{
    if (notification.object == self.window)
    {
        CocosScene* cs = [CocosScene cocosScene];
    
        if ([[CCDirector sharedDirector] isPaused])
        {
            [[CCDirector sharedDirector] resume];
            cs.paused = NO;
        }
    }
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    if (notification.object == guiWindow)
    {
        [guiView setSubviews:[NSArray array]];
        [[CocosScene cocosScene].notesLayer showAllNotesLabels];
    }
}

- (void) windowDidResize:(NSNotification *)notification
{
    [sequenceHandler updateScroller];
}


#pragma mark Populating menus

- (void) updateResolutionMenu
{
    if (!currentDocument) return;
    
    // Clear the menu
    [menuResolution removeAllItems];
    
    // Add all new resolutions
    int i = 0;
    for (ResolutionSetting* resolution in currentDocument.resolutions)
    {
        NSString* keyEquivalent = @"";
        if (i < 10) keyEquivalent = [NSString stringWithFormat:@"%d",i+1];
        
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:resolution.name action:@selector(menuResolution:) keyEquivalent:keyEquivalent];
        item.target = self;
        item.tag = i;
        
        [menuResolution addItem:item];
        if (i == currentDocument.currentResolution) item.state = NSOnState;
        
        i++;
    }
}

- (void) updateTimelineMenu
{
    if (!currentDocument)
    {
        lblTimeline.stringValue = @"";
        lblTimelineChained.stringValue = @"";
        [menuTimelinePopup setEnabled:NO];
        [menuTimelineChainedPopup setEnabled:NO];
        return;
    }
    
    [menuTimelinePopup setEnabled:YES];
    [menuTimelineChainedPopup setEnabled:YES];
    
    // Clear menu
    [menuTimeline removeAllItems];
    [menuTimelineChained removeAllItems];
    
    int currentId = sequenceHandler.currentSequence.sequenceId;
    int chainedId = sequenceHandler.currentSequence.chainedSequenceId;
    
    // Add dummy item
    NSMenuItem* itemDummy = [[NSMenuItem alloc] initWithTitle:@"Dummy" action:NULL keyEquivalent:@""];
    [menuTimelineChained addItem:itemDummy];
    
    // Add empty option for chained seq
    NSMenuItem* itemCh = [[NSMenuItem alloc] initWithTitle: @"No Chained Timeline" action:@selector(menuSetChainedSequence:) keyEquivalent:@""];
    itemCh.target = sequenceHandler;
    itemCh.tag = -1;
    if (chainedId == -1) [itemCh setState:NSOnState];
    [menuTimelineChained addItem:itemCh];
    
    // Add separator item
    [menuTimelineChained addItem:[NSMenuItem separatorItem]];
    
    for (SequencerSequence* seq in currentDocument.sequences)
    {
        // Add to sequence selector
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:seq.name action:@selector(menuSetSequence:) keyEquivalent:@""];
        item.target = sequenceHandler;
        item.tag = seq.sequenceId;
        if (currentId == seq.sequenceId) [item setState:NSOnState];
        [menuTimeline addItem:item];
        
        // Add to chained sequence selector
        itemCh = [[NSMenuItem alloc] initWithTitle: seq.name action:@selector(menuSetChainedSequence:) keyEquivalent:@""];
        itemCh.target = sequenceHandler;
        itemCh.tag = seq.sequenceId;
        if (chainedId == seq.sequenceId) [itemCh setState:NSOnState];
        [menuTimelineChained addItem:itemCh];
    }
    
    if (sequenceHandler.currentSequence) lblTimeline.stringValue = sequenceHandler.currentSequence.name;
    if (chainedId == -1)
    {
        lblTimelineChained.stringValue = @"No chained timeline";
    }
    else
    {
        for (SequencerSequence* seq in currentDocument.sequences)
        {
            if (seq.sequenceId == chainedId)
            {
                lblTimelineChained.stringValue = seq.name;
                break;
            }
        }
    }

    [animationPlaybackManager stop];
}

#pragma mark Document handling

- (BOOL) hasDirtyDocument
{
    NSArray* docs = [tabView tabViewItems];
    for (int i = 0; i < [docs count]; i++)
    {
        CCBDocument* doc = [(NSTabViewItem*)[docs objectAtIndex:i] identifier];
        if (doc.isDirty) return YES;
    }
    if ([[NSDocumentController sharedDocumentController] hasEditedDocuments])
    {
        return YES;
    }
    return NO;
}

- (void) updateDirtyMark
{
    [window setDocumentEdited:[self hasDirtyDocument]];
}

- (NSMutableDictionary*) docDataFromCurrentNodeGraph
{
    CCBDocumentDataCreator *dataCreator =
            [[CCBDocumentDataCreator alloc] initWithSceneGraph:[SceneGraph instance]
                                                      document:currentDocument
                                               projectSettings:projectSettings
                                                    sequenceId:sequenceHandler.currentSequence.sequenceId];
    return [dataCreator createData];
}

- (void) prepareForDocumentSwitch
{
    [self.window makeKeyWindow];
    CocosScene* cs = [CocosScene cocosScene];
		
    if (![self hasOpenedDocument]) return;
    currentDocument.data = [self docDataFromCurrentNodeGraph];
    currentDocument.stageZoom = [cs stageZoom];
    currentDocument.stageScrollOffset = [cs scrollOffset];
}

- (NSMutableArray*) updateResolutions:(NSMutableArray*) resolutions forDocDimensionType:(int) type
{
    NSMutableArray* updatedResolutions = [NSMutableArray array];
    
    if (type == kCCBDocDimensionsTypeNode)
    {
        if (projectSettings.designTarget == kCCBDesignTargetFlexible)
        {
            [updatedResolutions addObject:[ResolutionSetting settingIPhone]];
            [updatedResolutions addObject:[ResolutionSetting settingIPad]];
        }
        else
        {
            [updatedResolutions addObject:[ResolutionSetting settingFixed]];
        }
    }
    else if (type == kCCBDocDimensionsTypeLayer)
    {
        ResolutionSetting* settingDefault = [resolutions objectAtIndex:0];
        
        if (projectSettings.designTarget == kCCBDesignTargetFixed)
        {
            settingDefault.name = @"Fixed";
            settingDefault.scale = 2;
            settingDefault.ext = @"tablet phonehd";
            [updatedResolutions addObject:settingDefault];
        }
        else if (projectSettings.designTarget == kCCBDesignTargetFlexible)
        {
            settingDefault.name = @"Phone";
            settingDefault.scale = 1;
            settingDefault.ext = @"phone";
            [updatedResolutions addObject:settingDefault];
            
            ResolutionSetting* settingTablet = [settingDefault copy];
            settingTablet.name = @"Tablet";
            settingTablet.scale = projectSettings.tabletPositionScaleFactor;
            settingTablet.ext = @"tablet phonehd";
            [updatedResolutions addObject:settingTablet];
        }
    }
    else if (type == kCCBDocDimensionsTypeFullScreen)
    {
        if (projectSettings.defaultOrientation == kCCBOrientationLandscape)
        {
            // Full screen landscape
            if (projectSettings.designTarget == kCCBDesignTargetFixed)
            {
                [updatedResolutions addObject:[ResolutionSetting settingFixedLandscape]];
            }
            else if (projectSettings.designTarget == kCCBDesignTargetFlexible)
            {
                [updatedResolutions addObject:[ResolutionSetting settingIPhone5Landscape]];
                [updatedResolutions addObject:[ResolutionSetting settingIPadLandscape]];
                [updatedResolutions addObject:[ResolutionSetting settingIPhoneLandscape]];
            }
        }
        else
        {
            // Full screen portrait
            if (projectSettings.designTarget == kCCBDesignTargetFixed)
            {
                [updatedResolutions addObject:[ResolutionSetting settingFixedPortrait]];
            }
            else if (projectSettings.designTarget == kCCBDesignTargetFlexible)
            {
                [updatedResolutions addObject:[ResolutionSetting settingIPhone5Portrait]];
                [updatedResolutions addObject:[ResolutionSetting settingIPadPortrait]];
                [updatedResolutions addObject:[ResolutionSetting settingIPhonePortrait]];
            }
        }
    }
    
    return updatedResolutions;
}

- (void) replaceDocumentData:(NSMutableDictionary*)doc
{
//    SceneGraph* g = [SceneGraph instance];
    
    [loadedSelectedNodes removeAllObjects];
    
    BOOL centered = [[doc objectForKey:@"centeredOrigin"] boolValue];
    
    // Check for jsControlled
    jsControlled = [[doc objectForKey:@"jsControlled"] boolValue];
    
    int docDimType = [[doc objectForKey:@"docDimensionsType"] intValue];
    if (docDimType == kCCBDocDimensionsTypeNode) centered = YES;
    else centered = NO;
    
    if (docDimType == kCCBDocDimensionsTypeLayer) self.canEditStageSize = YES;
    else self.canEditStageSize = NO;
    
    // Setup stage & resolutions
    NSMutableArray* serializedResolutions = [doc objectForKey:@"resolutions"];
    if (serializedResolutions)
    {
        // Load resolutions
        NSMutableArray* resolutions = [NSMutableArray array];
        for (id serRes in serializedResolutions)
        {
            ResolutionSetting* resolution = [[ResolutionSetting alloc] initWithSerialization:serRes];
            [resolutions addObject:resolution];
        }
        
        resolutions = [self updateResolutions:resolutions forDocDimensionType:docDimType];
        
        currentDocument.docDimensionsType = docDimType;
        int currentResolution = [[doc objectForKey:@"currentResolution"] intValue];
        currentResolution = clampf(currentResolution, 0, resolutions.count - 1);
        ResolutionSetting* resolution = [resolutions objectAtIndex:currentResolution];
        
        // Save in current document
        currentDocument.resolutions = resolutions;
        currentDocument.currentResolution = currentResolution;
        
        [self updatePositionScaleFactor];
        
        // Update CocosScene
        [[CocosScene cocosScene] setStageSize:CGSizeMake(resolution.width, resolution.height) centeredOrigin: centered];
        
    }
    else
    {
        // Support old files where the current width and height was stored
        int stageW = [[doc objectForKey:@"stageWidth"] intValue];
        int stageH = [[doc objectForKey:@"stageHeight"] intValue];
        
        [[CocosScene cocosScene] setStageSize:CGSizeMake(stageW, stageH) centeredOrigin:centered];
        
        // Setup a basic resolution and attach it to the current document
        ResolutionSetting* resolution = [[ResolutionSetting alloc] init];
        resolution.width = stageW;
        resolution.height = stageH;
        resolution.centeredOrigin = centered;
        
        NSMutableArray* resolutions = [NSMutableArray arrayWithObject:resolution];
        currentDocument.resolutions = resolutions;
        currentDocument.currentResolution = 0;
    }
    [self updateResolutionMenu];
    
    ResolutionSetting* resolution = [currentDocument.resolutions objectAtIndex:currentDocument.currentResolution];
    
    // Stage border
    [[CocosScene cocosScene] setStageBorder:[[doc objectForKey:@"stageBorder"] intValue]];
    
    // Stage color
    NSNumber *stageColorObject = [doc objectForKey: @"stageColor"];
    int stageColor;
    if (stageColorObject != nil)
    {
        stageColor = [stageColorObject intValue];
    }
    else
    {
        if (currentDocument.docDimensionsType == kCCBDocDimensionsTypeNode)
        {
            stageColor = kCCBCanvasColorGray;
        }
        else
        {
            stageColor = kCCBCanvasColorBlack;
        }
    }
    currentDocument.stageColor = stageColor;
    [self updateCanvasColor];
    [menuItemStageColor setEnabled: currentDocument.docDimensionsType != kCCBDocDimensionsTypeFullScreen];

    // Setup sequencer timelines
    NSMutableArray* serializedSequences = [doc objectForKey:@"sequences"];
    if (serializedSequences)
    {
        // Load from the file
        int currentSequenceId = [[doc objectForKey:@"currentSequenceId"] intValue];
        SequencerSequence* currentSeq = NULL;
        
        NSMutableArray* sequences = [NSMutableArray array];
        for (id serSeq in serializedSequences)
        {
            SequencerSequence* seq = [[SequencerSequence alloc] initWithSerialization:serSeq];
            [sequences addObject:seq];
            
            if (seq.sequenceId == currentSequenceId)
            {
                currentSeq = seq;
            }
        }
        
        currentDocument.sequences = sequences;
        sequenceHandler.currentSequence = currentSeq;
    }
    else
    {
        // Setup a default timeline
        NSMutableArray* sequences = [NSMutableArray array];
    
        SequencerSequence* seq = [[SequencerSequence alloc] init];
        seq.name = @"Default Timeline";
        seq.sequenceId = 0;
        seq.autoPlay = YES;
        [sequences addObject:seq];
    
        currentDocument.sequences = sequences;
        sequenceHandler.currentSequence = seq;
    }
    
    // Process contents
    CCNode* loadedRoot = [CCBReaderInternal nodeGraphFromDocumentDictionary:doc parentSize:CGSizeMake(resolution.width, resolution.height)];
    
    NSMutableArray* loadedJoints = [NSMutableArray array];
    if(doc[@"joints"] != nil)
    {
        for (NSDictionary * jointDict in doc[@"joints"])
        {
            CCNode * joint = [CCBReaderInternal nodeGraphFromDictionary:jointDict parentSize:CGSizeMake(resolution.width, resolution.height) withParentGraph:loadedRoot];
            
            if(joint)
            {
                [loadedJoints addObject:joint];
            }
        }
    }
    
    // Replace open document
    [self deselectAll];
    
    SceneGraph * g = [SceneGraph setInstance:[[SceneGraph alloc] initWithProjectSettings:projectSettings]];
    [g.joints deserialize:doc[@"SequencerJoints"]];
    g.rootNode = loadedRoot;
    
    [loadedJoints forEach:^(CCBPhysicsJoint * child, int idx) {
        [g.joints addJoint:child];
    }];

	[CCBReaderInternal postDeserializationFixup:g.rootNode];

    
    [[CocosScene cocosScene] replaceSceneNodes:g];
    [outlineHierarchy reloadData];
    [sequenceHandler updateOutlineViewSelection];
    [_inspectorController updateInspectorFromSelection];
    
    [sequenceHandler updateExpandedForNode:g.rootNode];
    [sequenceHandler.outlineHierarchy expandItem:g.joints];
    
    // Setup guides
    id guides = [doc objectForKey:@"guides"];
    if (guides)
    {
        [[CocosScene cocosScene].guideLayer loadSerializedGuides:guides];
    }
    else
    {
        [[CocosScene cocosScene].guideLayer removeAllGuides];
    }
    
    // Setup notes
    id notes = [doc objectForKey:@"notes"];
    if (notes)
    {
        [[CocosScene cocosScene].notesLayer loadSerializedNotes:notes];
    }
    else
    {
        [[CocosScene cocosScene].notesLayer removeAllNotes];
    }
    
    // Restore Grid Spacing
    id gridspaceWidth  = [doc objectForKey:@"gridspaceWidth"];
    id gridspaceHeight = [doc objectForKey:@"gridspaceHeight"];
    if(gridspaceWidth && gridspaceHeight) {
        CGSize gridspace = CGSizeMake([gridspaceWidth intValue],[gridspaceHeight intValue]);
        [[CocosScene cocosScene].guideLayer setGridSize:gridspace];
   }

    // Restore selections
    self.selectedNodes = loadedSelectedNodes;
    
    //[self updateJSControlledMenu];
    [self updateCanvasBorderMenu];
    
    [self willChangeValueForKey:@"showJoints"];
    [self didChangeValueForKey:@"showJoints"];

    [lightingHandler refreshAll];
}

- (void) switchToDocument:(CCBDocument*) document forceReload:(BOOL)forceReload
{
    if (!forceReload && [document.filePath isEqualToString:currentDocument.filePath]) return;

    [animationPlaybackManager stop];

    [self prepareForDocumentSwitch];
    
    self.currentDocument = document;
    
    NSMutableDictionary* doc = document.data;
    
    [self replaceDocumentData:doc];
    
    [self updateResolutionMenu];
    [self updateTimelineMenu];
    //[self updateStateOriginCenteredMenu];
    
    CocosScene* cs = [CocosScene cocosScene];
    [cs setStageZoom:document.stageZoom];
    [cs setScrollOffset:document.stageScrollOffset];
    
    // Make sure timeline is up to date
    [sequenceHandler updatePropertiesToTimelinePosition];
}

-(void)fixupUUID:(CCBDocument*)doc dict:(NSMutableDictionary*)dict
{
    if(!dict[@"UUID"])
    {
        dict[@"UUID"] = @(doc.UUID);
        [doc getAndIncrementUUID];
    }
    
    if(dict[@"children"])
    {
        for (NSMutableDictionary * child in dict[@"children"])
        {
            [self fixupUUID:doc dict:child];
        }
        
    }
}


-(void)fixupDoc:(CCBDocument*) doc
{
    //If UUID is unset, it means the doc is out of date. Fixup.
    if(doc.UUID == 0x0)
    {
        doc.UUID = 0x1;
        [self fixupUUID:doc dict: doc.data[@"nodeGraph"]];

    }
}

- (void) switchToDocument:(CCBDocument*) document
{
    [self switchToDocument:document forceReload:NO];
}

- (void) addDocument:(CCBDocument*) doc
{
    [self addTab:doc];
}

- (void) closeLastDocument
{
    [self deselectAll];
    
    SceneGraph * g = [SceneGraph setInstance:[[SceneGraph alloc] initWithProjectSettings:projectSettings]];
    [[CocosScene cocosScene] replaceSceneNodes: g];
    [[CocosScene cocosScene] setStageSize:CGSizeMake(0, 0) centeredOrigin:YES];
    [[CocosScene cocosScene].guideLayer removeAllGuides];
    [[CocosScene cocosScene].notesLayer removeAllNotes];
    [[CocosScene cocosScene].rulerLayer mouseExited:NULL];
    [self setupExtras]; // Reset
    self.currentDocument = NULL;
    sequenceHandler.currentSequence = NULL;
    
    [self updateTimelineMenu];
    [outlineHierarchy reloadData];
    
    //[resManagerPanel.window setIsVisible:NO];
    
    self.hasOpenedDocument = NO;
}

- (CCBDocument*) findDocumentFromFile:(NSString*)file
{
    NSArray* items = [tabView tabViewItems];
    for (int i = 0; i < [items count]; i++)
    {
        CCBDocument* doc = [(NSTabViewItem*)[items objectAtIndex:i] identifier];
        if ([doc.filePath isEqualToString:file]) return doc;
    }
    return NULL;
}

- (NSTabViewItem*) tabViewItemFromDoc:(CCBDocument*)docRef
{
    NSArray* items = [tabView tabViewItems];
    for (int i = 0; i < [items count]; i++)
    {
        CCBDocument* doc = [(NSTabViewItem*)[items objectAtIndex:i] identifier];
        if (doc == docRef) return [items objectAtIndex:i];
    }
    return NULL;
}

// A path can be a folder not only a file. Set includeViewWithinFolderPath to YES to return
// the first view that is within a given folder path
- (NSTabViewItem *)tabViewItemFromPath:(NSString *)path includeViewWithinFolderPath:(BOOL)includeViewWithinFolderPath
{
	NSArray *items = [tabView tabViewItems];
	for (NSUInteger i = 0; i < [items count]; i++)
	{
		CCBDocument *doc = [(NSTabViewItem *) [items objectAtIndex:i] identifier];
		if ([doc.filePath isEqualToString:path]
			|| (includeViewWithinFolderPath && [doc isWithinPath:path]))
		{
			return [items objectAtIndex:i];
		}
	}
	return NULL;
}

- (void) checkForTooManyDirectoriesInCurrentDoc
{
    if (!currentDocument) return;
    
    if ([ResourceManager sharedManager].tooManyDirectoriesAdded)
    {
        // Close document if it has too many sub directories
        NSTabViewItem* item = [self tabViewItemFromDoc:currentDocument];
        [tabView removeTabViewItem:item];
        
        [ResourceManager sharedManager].tooManyDirectoriesAdded = NO;
        
        // Notify the user
        [[AppDelegate appDelegate] modalDialogTitle:@"Too Many Directories" message:@"You have created or opened a file which is in a directory with very many sub directories. Please save your ccb-files in a directory together with the resources you use in your project."];
    }
}

- (BOOL) checkForTooManyDirectoriesInCurrentProject
{
    if (!projectSettings) return NO;
    
    if ([ResourceManager sharedManager].tooManyDirectoriesAdded)
    {
        [self closeProject];
        
        [ResourceManager sharedManager].tooManyDirectoriesAdded = NO;
        
        // Notify the user
        [[AppDelegate appDelegate] modalDialogTitle:@"Too Many Directories" message:@"You have created or opened a project which is in a directory with very many sub directories. Please save your project-files in a directory together with the resources you use in your project."];
        return NO;
    }
    return YES;
}

- (void) updateResourcePathsFromProjectSettings
{
    [[ResourceManager sharedManager] setActiveDirectoriesWithFullReset:[projectSettings absoluteResourcePaths]];
}

- (void) closeProject
{
    while ([tabView numberOfTabViewItems] > 0)
    {
        NSTabViewItem* item = [self tabViewItemFromDoc:currentDocument];
        if (!item) return;
        
        if ([self tabView:tabView shouldCloseTabViewItem:item])
        {
            [tabView removeTabViewItem:item];
        }
        else
        {
            // Aborted close project
            return;
        }
    }
    
    [window setTitle:@"SpriteBuilder"];

    [self.projectSettings store];

    // Remove resource paths
    self.projectSettings = NULL;
    _openPathsController.projectSettings = nil;

    [[ResourceManager sharedManager] removeAllDirectories];
    
    // Remove language file
    localizationEditorHandler.managedFile = NULL;
    
    [self updateWarningsButton];
    [self updateSmallTabBarsEnabled];
    
    self.window.representedFilename = @"";
}

- (BOOL) openProject:(NSString*) fileName
{
    if (![fileName hasSuffix:@".spritebuilder"])
    {
        return NO;
    }

    [self closeProject];
    
    // Add to recent list of opened documents
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:fileName]];
    
    // Convert folder to actual project file
    NSString* projName = [[fileName lastPathComponent] stringByDeletingPathExtension];
    fileName = [[fileName stringByAppendingPathComponent:projName] stringByAppendingPathExtension:@"ccbproj"];
    
    // Load the project file
    NSMutableDictionary* projectDict = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];
    if (!projectDict)
    {
        [self modalDialogTitle:@"Invalid Project File" message:@"Failed to open the project. File may be missing or invalid."];
        return NO;
    }
    
    ProjectSettings *prjctSettings = [[ProjectSettings alloc] initWithSerialization:projectDict];
    if (!prjctSettings)
    {
        [self modalDialogTitle:@"Invalid Project File" message:@"Failed to open the project. File is invalid or is created with a newer version of SpriteBuilder."];
        return NO;
    }
    prjctSettings.projectPath = fileName;
    [prjctSettings store];

    // inject new project settings
    self.projectSettings = prjctSettings;
    _resourceCommandController.projectSettings = projectSettings;
    projectOutlineHandler.projectSettings = projectSettings;
    [ResourceManager sharedManager].projectSettings = projectSettings;
    _openPathsController.projectSettings = projectSettings;

    // Update resource paths
    [self updateResourcePathsFromProjectSettings];

    // Update Node Plugins list
	[plugInNodeViewHandler showNodePluginsForEngine:prjctSettings.engine];
	
    BOOL success = [self checkForTooManyDirectoriesInCurrentProject];
    if (!success)
    {
        return NO;
    }

    ProjectMigrator *migrator = [[ProjectMigrator alloc] initWithProjectSettings:projectSettings];
    [migrator migrate];

    // Load or create language file
    NSString* langFile = [[ResourceManager sharedManager].mainActiveDirectoryPath stringByAppendingPathComponent:@"Strings.ccbLang"];
    localizationEditorHandler.managedFile = langFile;
    
    // Update the title of the main window
    [window setTitle:[NSString stringWithFormat:@"%@ - SpriteBuilder", [[fileName stringByDeletingLastPathComponent] lastPathComponent]]];
    
    // Open ccb file for project if there is only one
    NSArray* resPaths = prjctSettings.absoluteResourcePaths;
    if (resPaths.count > 0)
    {
        NSString* resPath = [resPaths objectAtIndex:0];
        
        NSArray* resDir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resPath error:NULL];
        
        int numCCBFiles = 0;
        NSString* ccbFile = NULL;
        for (NSString* file in resDir)
        {
            if ([file hasSuffix:@".ccb"])
            {
                ccbFile = file;
                numCCBFiles++;
                
                if (numCCBFiles > 1) break;
            }
        }
        
        if (numCCBFiles == 1)
        {
            // Open the ccb file
            [self openFile:[resPath stringByAppendingPathComponent:ccbFile]];
        }
    }
    
    [self updateWarningsButton];
    [self updateSmallTabBarsEnabled];

    Cocos2dUpdater *cocos2dUpdater = [[Cocos2dUpdater alloc] initWithAppDelegate:self projectSettings:projectSettings];
    [cocos2dUpdater updateAndBypassIgnore:NO];

    self.window.representedFilename = [fileName stringByDeletingLastPathComponent];

    return YES;
}

- (void) openFile:(NSString*)filePath
{
	[(CCGLView*)[[CCDirector sharedDirector] view] lockOpenGLContext];
    
    // Check if file is already open
    CCBDocument* openDoc = [self findDocumentFromFile:filePath];
    if (openDoc)
    {
        [tabView selectTabViewItem:[self tabViewItemFromDoc:openDoc]];
        return;
    }
    
    [self prepareForDocumentSwitch];
    
    CCBDocument *newDoc = [[CCBDocument alloc] initWithContentsOfFile:filePath];

    [self switchToDocument:newDoc];
     
    [self addDocument:newDoc];
    self.hasOpenedDocument = YES;
    
    [self checkForTooManyDirectoriesInCurrentDoc];
    
    // Remove selections
    physicsHandler.selectedNodePhysicsBody = NULL;
    [self setSelectedNodes:NULL];
    
	[(CCGLView*)[[CCDirector sharedDirector] view] unlockOpenGLContext];
}

- (void) saveFile:(NSString*) fileName
{
    currentDocument.filePath = fileName;
    currentDocument.data = [self docDataFromCurrentNodeGraph];
    [currentDocument store];
    
    currentDocument.isDirty = NO;
    NSTabViewItem* item = [self tabViewItemFromDoc:currentDocument];
    
    if (item)
    {
        [tabBar setIsEdited:NO ForTabViewItem:item];
        [self updateDirtyMark];
    }
        
    [currentDocument.undoManager removeAllActions];
    currentDocument.lastEditedProperty = NULL;
    
    // Generate preview
    
    // Reset to first frame in first timeline in first resolution
    float currentTime = sequenceHandler.currentSequence.timelinePosition;
    int currentResolution = currentDocument.currentResolution;
    SequencerSequence* currentSeq = sequenceHandler.currentSequence;
    
    sequenceHandler.currentSequence = [currentDocument.sequences objectAtIndex:0];
    sequenceHandler.currentSequence.timelinePosition = 0;
    [self reloadResources];
    //[PositionPropertySetter refreshAllPositions];
    
    // Save preview
    [[CocosScene cocosScene] savePreviewToFile:[fileName stringByAppendingPathExtension:PNG_PREVIEW_IMAGE_SUFFIX]];
    
    // Restore resolution and timeline
    currentDocument.currentResolution = currentResolution;
    sequenceHandler.currentSequence = currentSeq;
    [self reloadResources];
    //[PositionPropertySetter refreshAllPositions];
    sequenceHandler.currentSequence.timelinePosition = currentTime;
    
    [projectOutlineHandler updateSelectionPreview];
}

- (void) newFile:(NSString*) fileName type:(int)type resolutions: (NSMutableArray*) resolutions;
{
    BOOL centered = NO;
    if (type == kCCBNewDocTypeNode ||
        type == kCCBNewDocTypeParticleSystem ||
        type == kCCBNewDocTypeSprite) centered = YES;
    
    int docDimType = kCCBDocDimensionsTypeNode;
    if (type == kCCBNewDocTypeScene) docDimType = kCCBDocDimensionsTypeFullScreen;
    else if (type == kCCBNewDocTypeLayer) docDimType = kCCBDocDimensionsTypeLayer;
    
    NSString* class = NULL;
    if (type == kCCBNewDocTypeNode ||
        type == kCCBNewDocTypeLayer) class = @"CCNode";
    else if (type == kCCBNewDocTypeScene) class = @"CCNode";
    else if (type == kCCBNewDocTypeSprite) class = @"CCSprite";
    else if (type == kCCBNewDocTypeParticleSystem) class = @"CCParticleSystem";
    
    [[UsageManager sharedManager] sendEvent:[NSString stringWithFormat:@"new_file_%@",class]];
    
    resolutions = [self updateResolutions:resolutions forDocDimensionType:docDimType];
    
    ResolutionSetting* resolution = [resolutions objectAtIndex:0];
    CGSize stageSize = CGSizeMake(resolution.width, resolution.height);
    
    // Close old doc if neccessary
    CCBDocument* oldDoc = [self findDocumentFromFile:fileName];
    if (oldDoc)
    {
        NSTabViewItem* item = [self tabViewItemFromDoc:oldDoc];
        if (item) [tabView removeTabViewItem:item];
    }
    
    [self prepareForDocumentSwitch];
    
    [[CocosScene cocosScene].notesLayer removeAllNotes];
    
    [self deselectAll];
    [[CocosScene cocosScene] setStageSize:stageSize centeredOrigin:centered];
    
    if (type == kCCBNewDocTypeScene)
    {
        [[CocosScene cocosScene] setStageBorder:0];
    }
    else
    {
        [[CocosScene cocosScene] setStageBorder:1];
    }
    
    // Create new node
    SceneGraph * g = [SceneGraph setInstance:[[SceneGraph alloc] initWithProjectSettings:projectSettings]];
    g.rootNode = [[PlugInManager sharedManager] createDefaultNodeOfType:class];
    g.joints.node = [CCNode node];
    [[CocosScene cocosScene] replaceSceneNodes:g];
    
    if (type == kCCBNewDocTypeScene)
    {
        // Set default contentSize to 100% x 100% for scenes
        [PositionPropertySetter setSize:NSMakeSize(1, 1) type:CCSizeTypeNormalized forNode:[CocosScene cocosScene].rootNode prop:@"contentSize"];
    }
    else if (type == kCCBNewDocTypeLayer)
    {
        // Set contentSize to w x h in scaled coordinates for layers
        [PositionPropertySetter setSize:NSMakeSize(resolution.width, resolution.height) type:CCSizeTypePoints forNode:[CocosScene cocosScene].rootNode prop:@"contentSize"];
    }
    
    [outlineHierarchy reloadData];
    [sequenceHandler updateOutlineViewSelection];
    [_inspectorController updateInspectorFromSelection];
    
    self.currentDocument = [[CCBDocument alloc] init];
    self.currentDocument.resolutions = resolutions;
    self.currentDocument.currentResolution = 0;
    self.currentDocument.docDimensionsType = docDimType;
    
    if (type == kCCBNewDocTypeNode)
    {
        self.currentDocument.stageColor = kCCBCanvasColorGray;
    }
    else
    {
        self.currentDocument.stageColor = kCCBCanvasColorBlack;
    }

    [self updateResolutionMenu];
    
    [self saveFile:fileName];
    
    [self addDocument:currentDocument];
    
    // Setup a default timeline
    NSMutableArray* sequences = [NSMutableArray array];
    
    SequencerSequence* seq = [[SequencerSequence alloc] init];
    seq.name = @"Default Timeline";
    seq.sequenceId = 0;
    seq.autoPlay = YES;
    [sequences addObject:seq];
    
    currentDocument.sequences = sequences;
    sequenceHandler.currentSequence = seq;
    
    
    self.hasOpenedDocument = YES;
    
    //[self updateStateOriginCenteredMenu];
    
    [[CocosScene cocosScene] setStageZoom:1];
    [[CocosScene cocosScene] setScrollOffset:ccp(0,0)];
    
    [self checkForTooManyDirectoriesInCurrentDoc];

    [[ResourceManager sharedManager] updateForNewFile:fileName];
}


- (NSString*) findProject:(NSString*) path
{
	NSString* projectFile = nil;
	NSFileManager* fm = [NSFileManager defaultManager];
    
	NSArray* files = [fm contentsOfDirectoryAtPath:path error:NULL];
	for( NSString* file in files )
	{
		if( [file hasSuffix:@".ccbproj"] )
		{
			projectFile = [path stringByAppendingPathComponent:file];
			break;
		}
	}
	return projectFile;
}

- (void)openFiles:(NSArray*)filenames
{
	for( NSString* filename in filenames )
	{
		[self openProject:filename];		
	}
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	// must wait for resource manager & rest of app to have completed the launch process before opening file(s)
	if (_applicationLaunchComplete == NO)
	{
		NSAssert(delayOpenFiles == NULL, @"This shouldn't be set to anything since this value will only get applied once.");
		delayOpenFiles = [[NSMutableArray alloc] initWithArray:filenames];
	}
	else 
	{
		[self openFiles:filenames];
	}
}

- (IBAction)menuResetSpriteBuilder:(id)sender
{
    NSAlert* alert = [NSAlert alertWithMessageText:@"Reset SpriteBuilder" defaultButton:@"Cancel" alternateButton:@"Reset SpriteBuilder" otherButton:NULL informativeTextWithFormat:@"Are you sure you want to reset SpriteBuilder? This action will remove all your custom template and settings and cannot be undone."];
    [alert setAlertStyle:NSWarningAlertStyle];
    NSInteger result = [alert runModal];
    if (result == NSAlertDefaultReturn) return;
    
    [self setSelectedNodes:NULL];
    [self menuCleanCacheDirectories:sender];
    [_propertyInspectorTemplateHandler installDefaultTemplatesReplace:YES];
    [_propertyInspectorTemplateHandler loadTemplateLibrary];
    
    [NSUserDefaults resetStandardUserDefaults];
}

#pragma mark Undo

- (void) revertToState:(id)state
{
    [self saveUndoState];
    [self replaceDocumentData:state];
}

- (void) saveUndoStateWillChangeProperty:(NSString*)prop
{
    if (!currentDocument
        || (prop && [currentDocument.lastEditedProperty isEqualToString:prop]))
    {
        return;
    }

    currentDocument.isDirty = YES;
    currentDocument.lastEditedProperty = prop;

    NSMutableDictionary* doc = [self docDataFromCurrentNodeGraph];
    [currentDocument.undoManager registerUndoWithTarget:self selector:@selector(revertToState:) object:doc];

    NSTabViewItem* item = [self tabViewItemFromDoc:currentDocument];
    [tabBar setIsEdited:YES ForTabViewItem:item];

    [self updateDirtyMark];
}

- (void) saveUndoState
{
    [self saveUndoStateWillChangeProperty:NULL];
}

#pragma mark Menu options

- (BOOL) addCCObject:(CCNode *)child toParent:(CCNode*)parent atIndex:(int)index
{
	if (!child || !parent)
	{
		return NO;
	}

	NSError *error;
	if (![self canChildBeAddedToParent:child parent:parent error:&error])
	{
		self.errorDescription = error.localizedDescription;
		return NO;
	}
    
    [self saveUndoState];
    
    // Add object and change zOrder of objects after this child
    if (index == CCNODE_INDEX_LAST)
    {
        // Add at end of array
		[parent addChild:child z:[parent.children count]];
    }
    else
    {
        // Update zValues of children after this node
        NSArray* children = parent.children;
        for (NSUInteger i = (NSUInteger)index; i < [children count]; i++)
        {
            CCNode *aChild = children[i];
            aChild.zOrder += 1;
        }
		[parent addChild:child z:index];
        [parent sortAllChildren];
    }
    
    if(parent.hidden)
    {
        child.hidden = YES;
    }

    //Set an unset UUID
    if(child.UUID == 0x0)
    {
		child.UUID = [currentDocument getAndIncrementUUID];
    }
    
    [outlineHierarchy reloadData];
    [self setSelectedNodes:@[child]];
    [_inspectorController updateInspectorFromSelection];
    
    [lightingHandler refreshStageLightAndMenu];
    
    return YES;
}

- (BOOL)canChildBeAddedToParent:(CCNode *)child parent:(CCNode *)parent error:(NSError **)error
{
	NodeInfo *parentInfo = parent.userObject;
    NodeInfo *childInfo = child.userObject;

	if (!parentInfo.plugIn.canHaveChildren)
	{
		if (error)
		{
			NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"You cannot add children to a %@", parentInfo.plugIn.nodeClassName] };
			*error = [NSError errorWithDomain:SBErrorDomain code:SBNodeDoesNotSupportChildrenError userInfo:errorDictionary];
		}
		return NO;
	}

	if ([self doesToBeAddedChildRequireSpecificParent:child parent:parent])
	{
		if (error)
		{
			NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"A %@ must be added to a %@", childInfo.plugIn.nodeClassName, childInfo.plugIn.requireParentClass] };
			*error = [NSError errorWithDomain:SBErrorDomain code:SBChildRequiresSpecificParentError userInfo:errorDictionary];
		}
		return NO;
	}

	if ([self doesParentPermitChildToBeAdded:parent child:child])
	{
		if (error)
		{
			NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"You cannot add a %@ to a %@", childInfo.plugIn.nodeClassName, parentInfo.plugIn.nodeClassName] };
			*error = [NSError errorWithDomain:SBErrorDomain code:SBParentDoesNotPermitSpecificChildrenError userInfo:errorDictionary];
		}
		return NO;
	}
	return YES;
}

- (BOOL)doesParentPermitChildToBeAdded:(CCNode *)parent child:(CCNode *)child
{
	NodeInfo *parentInfo = parent.userObject;
    NodeInfo *childInfo = child.userObject;

	NSArray*requiredChildren = parentInfo.plugIn.requireChildClass;
	return (requiredChildren
			&& [requiredChildren indexOfObject:childInfo.plugIn.nodeClassName] == NSNotFound);
}

- (BOOL)doesToBeAddedChildRequireSpecificParent:(CCNode *)toBeAddedChild parent:(CCNode *)parent
{
	NodeInfo* nodeInfoParent = parent.userObject;
    NodeInfo* nodeInfo = toBeAddedChild.userObject;

	NSString* requireParentClass = nodeInfo.plugIn.requireParentClass;
	return (requireParentClass
			&& ![requireParentClass isEqualToString: nodeInfoParent.plugIn.nodeClassName]);
}

- (BOOL) addCCObject:(CCNode *)obj toParent:(CCNode *)parent
{
    return [self addCCObject:obj toParent:parent atIndex:CCNODE_INDEX_LAST];
}

- (BOOL) addCCObject:(CCNode*)obj asChild:(BOOL)asChild
{
    SceneGraph* g = [SceneGraph instance];
    
    CCNode* parent;
    if (!self.selectedNode)
    {
        parent = g.rootNode;
    }
    else if (self.selectedNode == g.rootNode)
    {
        parent = g.rootNode;
    }
    else
    {
        parent = self.selectedNode.parent;
    }
    
    if (asChild)
    {
        parent = self.selectedNode;
        
        if(!parent && !g.rootNode)
            return NO;
        
        if (!parent)
        {
            self.selectedNodes = [NSArray arrayWithObject: g.rootNode];
        }
    }
    
    
    BOOL success = [self addCCObject:obj toParent:parent];
    
    if (!success && !asChild)
    {
        // If failed to add the object, attempt to add it as a child instead
        return [self addCCObject:obj asChild:YES];
    }
    
    return success;
}

- (CCNode*) addPlugInNodeNamed:(NSString*)name asChild:(BOOL) asChild
{
    [animationPlaybackManager stop];

    self.errorDescription = NULL;
    CCNode* node = [[PlugInManager sharedManager] createDefaultNodeOfType:name];
    BOOL success = [self addCCObject:node asChild:asChild];
    
    if (!success && self.errorDescription)
    {
        node = NULL;
        [self modalDialogTitle:@"Failed to Add Object" message:self.errorDescription];
    }
    
    return node;
}

- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt parent:(CCNode*)parent
{
    [animationPlaybackManager stop];

    NodeInfo* info = parent.userObject;
    PlugInNode* plugIn = info.plugIn;
    
    if (!spriteFile) spriteFile = @"";
    if (!spriteSheetFile) spriteSheetFile = @"";
    
    NSString* class = plugIn.dropTargetSpriteFrameClass;
    NSString* prop = plugIn.dropTargetSpriteFrameProperty;
    
    if (class && prop)
    {
        // Create the node
        CCNode* node = [[PlugInManager sharedManager] createDefaultNodeOfType:class];
        
        // Round position
        pt.x = roundf(pt.x);
        pt.y = roundf(pt.y);
        
        // Set its position
        [PositionPropertySetter setPosition:NSPointFromCGPoint(pt) forNode:node prop:@"position"];
        
        [CCBReaderInternal setProp:prop ofType:@"SpriteFrame" toValue:[NSArray arrayWithObjects:spriteSheetFile, spriteFile, nil] forNode:node parentSize:CGSizeZero withParentGraph:nil];
        // Set it's displayName to the name of the spriteFile
        node.displayName = [[spriteFile lastPathComponent] stringByDeletingPathExtension];
        [self addCCObject:node toParent:parent];
    }
}

- (void) dropAddSpriteNamed:(NSString*)spriteFile inSpriteSheet:(NSString*)spriteSheetFile at:(CGPoint)pt
{
    // Sprite dropped in working canvas
    
    CCNode* node = self.selectedNode;
    if (!node || node.plugIn.isJoint)
        node = [CocosScene cocosScene].rootNode;
    
    CCNode* parent = node.parent;
    NodeInfo* info = parent.userObject;
    
    if (info.plugIn.acceptsDroppedSpriteFrameChildren)
    {
        [self dropAddSpriteNamed:spriteFile inSpriteSheet:spriteSheetFile at:[parent convertToNodeSpace:pt] parent:parent];
        return;
    }
    
    info = node.userObject;
    if (info.plugIn.acceptsDroppedSpriteFrameChildren)
    {
        [self dropAddSpriteNamed:spriteFile inSpriteSheet:spriteSheetFile at:[node convertToNodeSpace:pt] parent:node];
    }
}

-(BOOL)showJoints
{
	return ![SceneGraph instance].joints.node.hidden;
}

-(void)setShowJoints:(BOOL)showJoints
{
	[SceneGraph instance].joints.node.hidden = !showJoints;
	[sequenceHandler.outlineHierarchy reloadItem:[SceneGraph instance].joints reloadChildren:YES];
}

-(void)addJoint:(NSString*)jointName at:(CGPoint)pt
{
    SceneGraph* g = [SceneGraph instance];
    
    CCNode* addedNode = [[PlugInManager sharedManager] createDefaultNodeOfType:jointName];
    addedNode.UUID = [[AppDelegate appDelegate].currentDocument getAndIncrementUUID];

    
    [g.joints addJoint:(CCBPhysicsJoint*)addedNode];
    

    [PositionPropertySetter setPosition:[addedNode.parent convertToNodeSpace:pt] forNode:addedNode prop:@"position"];
    
    [outlineHierarchy reloadData];
    [self setSelectedNodes: [NSArray arrayWithObject: addedNode]];
    [_inspectorController updateInspectorFromSelection];
}

- (void) gotoAutoplaySequence
{
	SequencerSequence * autoPlaySequence = [currentDocument.sequences findFirst:^BOOL(SequencerSequence * sequence, int idx) {
		return sequence.autoPlay;
	}];
	
	if(autoPlaySequence)
	{
		sequenceHandler.currentSequence = autoPlaySequence;
		sequenceHandler.currentSequence.timelinePosition = 0.0f;
	}
}

- (void) dropAddPlugInNodeNamed:(NSString*) nodeName at:(CGPoint)pt
{
    PlugInNode* pluginDescription = [[PlugInManager sharedManager] plugInNodeNamed:nodeName];
    if(pluginDescription.isJoint)
    {
		if(!sequenceHandler.currentSequence.autoPlay || sequenceHandler.currentSequence.timelinePosition != 0.0f)
		{
			[self modalDialogTitle:@"Changing Timeline" message:@"In order to add a new joint, you must be viewing the first frame of the 'autoplay' timeline." disableKey:@"AddJointSetSequencer"];
			
		
			[self gotoAutoplaySequence];
		}

		
        [self addJoint:nodeName at:pt];
        return;
    }
    
    // New node was dropped in working canvas
    CCNode* addedNode = [self addPlugInNodeNamed:nodeName asChild:NO];
    
        
    // Set position
    if (addedNode)
    {
        [PositionPropertySetter setPosition:[addedNode.parent convertToNodeSpace:pt] forNode:addedNode prop:@"position"];
        [_inspectorController updateInspectorFromSelection];
    }
}

- (void) dropAddPlugInNodeNamed:(NSString *)nodeName parent:(CCNode*)parent index:(int)idx
{
    CCNode* node = [[PlugInManager sharedManager] createDefaultNodeOfType:nodeName];
    
    [self addCCObject:node toParent:parent atIndex:idx];
}

- (void) dropAddCCBFileNamed:(NSString*)ccbFile at:(CGPoint)pt parent:(CCNode*)parent
{
    if (!parent)
    {
        if (self.selectedNode != [CocosScene cocosScene].rootNode)
        {
            parent = self.selectedNode.parent;
        }
        if (!parent) parent = [CocosScene cocosScene].rootNode;
        
        pt = [parent convertToNodeSpace:pt];
    }
    
    CCNode* node = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCBFile"];
    [NodeGraphPropertySetter setNodeGraphForNode:node andProperty:@"ccbFile" withFile:ccbFile parentSize:parent.contentSize];
    [PositionPropertySetter setPosition:NSPointFromCGPoint(pt) type:CCPositionTypePoints forNode:node prop:@"position"];
    [self addCCObject:node toParent:parent];
}

- (IBAction) copy:(id) sender
{
    //Copy warnings.
    if([[self window] firstResponder] == _warningTableView)
    {
        CCBWarning * warning = projectSettings.lastWarnings.warnings[_warningTableView.selectedRow];
        NSString * stringToWrite = warning.description;
        NSPasteboard* cb = [NSPasteboard generalPasteboard];
        
        [cb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
        [cb setString:stringToWrite forType:NSStringPboardType];
        return;
    }

    // Copy keyframes
    NSArray* keyframes = [sequenceHandler selectedKeyframesForCurrentSequence];
    if ([keyframes count] > 0)
    {
        NSMutableSet* propsSet = [NSMutableSet set];
        NSMutableSet* seqsSet = [NSMutableSet set];
        BOOL duplicatedProps = NO;
        BOOL hasNodeKeyframes = NO;
        BOOL hasChannelKeyframes = NO;
        
        for (int i = 0; i < keyframes.count; i++)
        {
            SequencerKeyframe* keyframe = [keyframes objectAtIndex:i];
            
            NSValue* seqVal = [NSValue valueWithPointer:(__bridge const void *)(keyframe.parent)];
            if (![seqsSet containsObject:seqVal])
            {
                NSString* propName = keyframe.name;
                
                if (propName)
                {
                    if ([propsSet containsObject:propName])
                    {
                        duplicatedProps = YES;
                        break;
                    }
                    [propsSet addObject:propName];
                    [seqsSet addObject:seqVal];
                    
                    hasNodeKeyframes = YES;
                }
                else
                {
                    hasChannelKeyframes = YES;
                }
            }
        }
        
        if (duplicatedProps)
        {
            [self modalDialogTitle:@"Failed to Copy" message:@"You can only copy keyframes from one node."];
            return;
        }
        
        if (hasChannelKeyframes && hasNodeKeyframes)
        {
            [self modalDialogTitle:@"Failed to Copy" message:@"You cannot copy sound/callback keyframes and node keyframes at once."];
            return;
        }
        
        NSString* clipType = kClipboardKeyFrames;
        if (hasChannelKeyframes)
        {
            clipType = kClipboardChannelKeyframes;
        }
        
        // Serialize keyframe
        NSMutableArray* serKeyframes = [NSMutableArray array];
        for (SequencerKeyframe* keyframe in keyframes)
        {
            [serKeyframes addObject:[keyframe serialization]];
        }
        NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:serKeyframes];
        NSPasteboard* cb = [NSPasteboard generalPasteboard];
        [cb declareTypes:[NSArray arrayWithObject:clipType] owner:self];
        [cb setData:clipData forType:clipType];
        
        return;
    }
    
    
    // Copy node
    if (!self.selectedNode)
        return;
    
    if(self.selectedNode.plugIn.isJoint)
        return;
    
    // Serialize selected node
    NSMutableDictionary* clipDict = [CCBWriterInternal dictionaryFromCCObject:self.selectedNode];
    NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:clipDict];
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    
    [cb declareTypes:[NSArray arrayWithObjects:@"com.cocosbuilder.node", nil] owner:self];
    [cb setData:clipData forType:@"com.cocosbuilder.node"];
}

-(void)updateUUIDs:(CCNode*)node
{
    node.UUID = [currentDocument getAndIncrementUUID];
	[node postCopyFixup];
    
    for (CCNode * child in node.children) {
        [self updateUUIDs:child];
    }
}

- (void) doPasteAsChild:(BOOL)asChild
{
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    NSString* type = [cb availableTypeFromArray:[NSArray arrayWithObjects:@"com.cocosbuilder.node", nil]];
    
    if (type)
    {
        [animationPlaybackManager stop];

        NSData* clipData = [cb dataForType:type];
        NSMutableDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        CGSize parentSize;
        if (asChild) parentSize = self.selectedNode.contentSize;
        else parentSize = self.selectedNode.parent.contentSize;
        
        CCNode* clipNode = [CCBReaderInternal nodeGraphFromDictionary:clipDict parentSize:parentSize];
		[CCBReaderInternal postDeserializationFixup:clipNode];
        [self updateUUIDs:clipNode];
        
        
        [self addCCObject:clipNode asChild:asChild];
        
        //We might have copy/cut/pasted and body. Fix it up.		
        [SceneGraph fixupReferences];
    }
}

- (IBAction) paste:(id) sender
{
    if (!currentDocument) return;
    
    // Paste keyframes
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    NSString* type = [cb availableTypeFromArray:[NSArray arrayWithObjects:kClipboardKeyFrames, kClipboardChannelKeyframes, nil]];
    
    if (type)
    {
        if (!self.selectedNode && [type isEqualToString:kClipboardKeyFrames])
        {
            [self modalDialogTitle:@"Paste Failed" message:@"You need to select a node to paste keyframes"];
            return;
        }
            
        // Unarchive keyframes
        NSData* clipData = [cb dataForType:type];
        NSMutableArray* serKeyframes = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        NSMutableArray* keyframes = [NSMutableArray array];
        
        // Save keyframes and find time of first kf
        float firstTime = MAXFLOAT;
        for (id serKeyframe in serKeyframes)
        {
            SequencerKeyframe* keyframe = [[SequencerKeyframe alloc] initWithSerialization:serKeyframe];
            if (keyframe.time < firstTime)
            {
                firstTime = keyframe.time;
            }
            [keyframes addObject:keyframe];
        }
            
        // Adjust times and add keyframes
        SequencerSequence* seq = sequenceHandler.currentSequence;
        
        for (SequencerKeyframe* keyframe in keyframes)
        {
            // Adjust time
            keyframe.time = [seq alignTimeToResolution:keyframe.time - firstTime + seq.timelinePosition];
            
            // Add the keyframe
            if ([type isEqualToString:kClipboardKeyFrames])
            {
                [self.selectedNode addKeyframe:keyframe forProperty:keyframe.name atTime:keyframe.time sequenceId:seq.sequenceId];
            }
            else if ([type isEqualToString:kClipboardChannelKeyframes])
            {
                if (keyframe.type == kCCBKeyframeTypeCallbacks)
                {
                    [seq.callbackChannel.seqNodeProp setKeyframe:keyframe];
                }
                else if (keyframe.type == kCCBKeyframeTypeSoundEffects)
                {
                    [seq.soundChannel.seqNodeProp setKeyframe:keyframe];
                }
                [keyframe.parent deleteKeyframesAfterTime:seq.timelineLength];
                [[SequencerHandler sharedHandler] redrawTimeline];
            }

            [[SequencerHandler sharedHandler] deleteDuplicateKeyframesForCurrentSequence];
        }
        
    }
    
    // Paste nodes
    [self doPasteAsChild:NO];
}

- (IBAction) pasteAsChild:(id)sender
{
    [self doPasteAsChild:YES];
}

- (void) deleteNode:(CCNode*)node
{
    SceneGraph* g = [SceneGraph instance];

    if (!node
        || node == g.rootNode)
    {
        return;
    }

    [self saveUndoState];
    
    // Change zOrder of nodes after this one
    int zOrder = node.zOrder;
    NSArray* siblings = [node.parent children];
    for (int i = zOrder+1; i < [siblings count]; i++)
    {
        CCNode* sibling = siblings[i];
        sibling.zOrder -= 1;
    }
    
    [node removeFromParentAndCleanup:YES];
    
    [node.parent sortAllChildren];
    [outlineHierarchy reloadData];
    
    [self deselectAll];
    [sequenceHandler updateOutlineViewSelection];

    [[NSNotificationCenter defaultCenter] postNotificationName:SCENEGRAPH_NODE_DELETED object:self userInfo:@{NOTIFICATION_USERINFO_KEY_NODE : node}];
    
    [lightingHandler refreshStageLightAndMenu];
}

- (IBAction) delete:(id) sender
{
    // First attempt to delete selected keyframes
	if ([sequenceHandler deleteSelectedKeyframesForCurrentSequence])
	{
		return;
	}

	// Then delete the selected node
    NSArray* nodesToDelete = [NSArray arrayWithArray:self.selectedNodes];
    for (CCNode* node in nodesToDelete)
    {
        [self deleteNode:node];
    }
}

- (IBAction) cut:(id) sender
{
    SceneGraph* g = [SceneGraph instance];
    if (self.selectedNode == g.rootNode)
    {
        [self modalDialogTitle:@"Failed to cut object" message:@"The root node cannot be removed"];
        return;
    }
    
    [self copy:sender];
    [self delete:sender];
}

- (void) moveSelectedObjectWithDelta:(CGPoint)delta
{
    if (self.selectedNodes.count == 0) return;
    
    for (CCNode* selectedNode in self.selectedNodes)
    {
        if(selectedNode.locked)
            continue;
        
        [self saveUndoStateWillChangeProperty:@"position"];
        
        // Get and update absolute position
        CGPoint absPos = selectedNode.positionInPoints;
        absPos = ccpAdd(absPos, delta);
        
        // Convert to relative position
        //CGSize parentSize = [PositionPropertySetter getParentSize:selectedNode];
        //CCPositionType positionType = [PositionPropertySetter positionTypeForNode:selectedNode prop:@"position"];
        NSPoint newPos = [selectedNode convertPositionFromPoints:absPos type:selectedNode.positionType];
        //NSPoint newPos = [PositionPropertySetter calcRelativePositionFromAbsolute:NSPointFromCGPoint(absPos) type:positionType];
        
        // Update the selected node
        [PositionPropertySetter setPosition:newPos forNode:selectedNode prop:@"position"];
        [PositionPropertySetter addPositionKeyframeForNode:selectedNode];
        
        [_inspectorController refreshProperty:@"position"];
    }
}

- (IBAction) menuNudgeObject:(id)sender
{
    int dir = (int)[sender tag];
    
    if (self.selectedNodes.count == 0) return;
    
    CGPoint delta = CGPointZero;
    if (dir == 0) delta = ccp(-1, 0);
    else if (dir == 1) delta = ccp(1, 0);
    else if (dir == 2) delta = ccp(0, 1);
    else if (dir == 3) delta = ccp(0, -1);
    
    [self moveSelectedObjectWithDelta:delta];
}

- (IBAction) menuMoveObject:(id)sender
{
    int dir = (int)[sender tag];
    
    if (self.selectedNodes.count == 0) return;
    
    CGPoint delta = CGPointZero;
    if (dir == 0) delta = ccp(-10, 0);
    else if (dir == 1) delta = ccp(10, 0);
    else if (dir == 2) delta = ccp(0, 10);
    else if (dir == 3) delta = ccp(0, -10);
    
    [self moveSelectedObjectWithDelta:delta];
}

- (IBAction) saveDocumentAs:(id)sender
{
    if (!currentDocument) return;
    
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    [saveDlg setAllowedFileTypes:[NSArray arrayWithObject:@"ccb"]];
	__block SavePanelLimiter* limiter = [[SavePanelLimiter alloc] initWithPanel:saveDlg];
    
    [saveDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            NSString *filename = [[saveDlg URL] path];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0),
                           dispatch_get_main_queue(), ^{
                [(CCGLView*)[[CCDirector sharedDirector] view] lockOpenGLContext];
                
                // Save file to new path
                [self saveFile:filename];
                
                // Close document
                [tabView removeTabViewItem:[self tabViewItemFromDoc:currentDocument]];
                
                // Open newly created document
                [self openFile:filename];
                
                [(CCGLView*)[[CCDirector sharedDirector] view] unlockOpenGLContext];
            });
        }
		
		// ensures the limiter remains in memory until the block finishes
		limiter = nil;
    }];
}

- (IBAction) saveDocument:(id)sender
{
    // Finish editing inspector
    if (![[self window] makeFirstResponder:[self window]])
    {
        return;
    }
    
    if (currentDocument && currentDocument.filePath)
    {
        [self saveFile:currentDocument.filePath];
    }
    else
    {
        [self saveDocumentAs:sender];
    }
}

- (IBAction) saveAllDocuments:(id)sender
{
    // Save all JS files
    //[[NSDocumentController sharedDocumentController] saveAllDocuments:sender]; //This API have no effects
    NSArray* JSDocs = [[NSDocumentController sharedDocumentController] documents];
    for (int i = 0; i < [JSDocs count]; i++)
    {
        NSDocument* doc = JSDocs[i];
        if (doc.isDocumentEdited)
        {
            [doc saveDocument:sender];
        }
    }
    
    // Save all CCB files
    CCBDocument* oldCurDoc = currentDocument;
    NSArray* docs = [tabView tabViewItems];
    for (int i = 0; i < [docs count]; i++)
    {
        CCBDocument* doc = [(NSTabViewItem*) docs[i] identifier];
         if (doc.isDirty)
         {
             [self switchToDocument:doc forceReload:NO];
             [self saveDocument:sender];
         }
    }
    [self switchToDocument:oldCurDoc forceReload:NO];
}

- (void)checkForDirtyDocumentAndPublishAsync:(BOOL)async
{
    if (!projectSettings.publishEnabledAndroid
        && !projectSettings.publishEnabledIOS)
    {
        if(async)
            [self modalDialogTitle:@"Published Failed" message:@"There are no configured publish target platforms. Please check your Publish Settings."];
        
        return;
    }
    
    // Check if there are unsaved documents
    if ([self hasDirtyDocument])
    {
        NSInteger result = NSAlertDefaultReturn;
        if(async)
        {
            NSAlert* alert = [NSAlert alertWithMessageText:@"Publish Project" defaultButton:@"Save All" alternateButton:@"Cancel" otherButton:@"Don't Save" informativeTextWithFormat:@"There are unsaved documents. Do you want to save before publishing?"];
            [alert setAlertStyle:NSWarningAlertStyle];
            result = [alert runModal];
        }
        
        switch (result) {
            case NSAlertDefaultReturn:
                [self saveAllDocuments:nil];
                // Falling through to publish
            case NSAlertOtherReturn:
                // Open progress window and publish
                [self publishStartAsync:async];
                break;
            default:
                break;
        }
    }
    else
    {
        [self publishStartAsync:async];
    }
}

- (void)publishStartAsync:(BOOL)async
{
    
    [[UsageManager sharedManager] sendEvent:[NSString stringWithFormat:@"project_publish_%@",projectSettings.publishEnvironment ? @"release" : @"develop"]];
    
    self.publisherController = [[CCBPublisherController alloc] init];
    _publisherController.projectSettings = projectSettings;
    _publisherController.packageSettings = [[ResourceManager sharedManager] loadAllPackageSettings];
    _publisherController.oldResourcePaths = [[ResourceManager sharedManager] oldResourcePaths];

    id __weak selfWeak = self;
    _publisherController.finishBlock = ^(CCBPublisher *aPublisher, CCBWarnings *someWarnings)
    {
        [selfWeak publisher:aPublisher finishedWithWarnings:someWarnings];
    };

    modalTaskStatusWindow = [[TaskStatusWindow alloc] initWithWindowNibName:@"TaskStatusWindow"];
    _publisherController.taskStatusUpdater = modalTaskStatusWindow;

    // Open progress window and publish
    if (async)
    {
        [_publisherController startAsync:YES];
        [self modalStatusWindowStartWithTitle:@"Publishing" isIndeterminate:NO onCancelBlock:^
        {
            [_publisherController cancel];
        }];
        [self modalStatusWindowUpdateStatusText:@"Starting up..."];
    }
    else
    {
        [_publisherController startAsync:NO];
    }

    [animationPlaybackManager stop];
}

- (void)publisher:(CCBPublisher *)publisher finishedWithWarnings:(CCBWarnings *)warnings
{
    [self modalStatusWindowFinish];
    
    // Update project view
    projectSettings.lastWarnings = warnings;
    [outlineProject reloadData];
    
    // Update warnings button in toolbar
    [self updateWarningsButton];
    
    if (warnings.warnings.count)
    {
        [projectViewTabs selectBarButtonIndex:3];
    }
}

- (IBAction) menuPublishProject:(id)sender
{
    [self checkForDirtyDocumentAndPublishAsync:YES];
}

- (IBAction) menuCleanCacheDirectories:(id)sender
{
    [CCBPublisherCacheCleaner cleanWithProjectSettings:projectSettings];
}

// Temporary utility function until new publish system is in place
- (IBAction)menuUpdateCCBsInDirectory:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    
    [openDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            NSArray* files = [openDlg URLs];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0),
                           dispatch_get_main_queue(), ^{
                [(CCGLView*)[[CCDirector sharedDirector] view] lockOpenGLContext];
                
                for (int i = 0; i < [files count]; i++)
                {
                    NSString* dirName = [[files objectAtIndex:i] path];
                    
                    NSArray* arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirName error:NULL];
                    for(NSString* file in arr)
                    {
                        if ([file hasSuffix:@".ccb"])
                        {
                            NSString* absPath = [dirName stringByAppendingPathComponent:file];
                            [self openFile:absPath];
                            [self saveFile:absPath];
                            //[self publishDocument:NULL];
                            [self performClose:sender];
                        }
                    }
                }
                
                [(CCGLView*)[[CCDirector sharedDirector] view] unlockOpenGLContext];
            });
        }
    }];
}

- (IBAction)menuOpenProjectInXCode:(id)sender
{
    NSString *xcodePrjPath = [projectSettings.projectPath stringByReplacingOccurrencesOfString:@".ccbproj" withString:@".xcodeproj"];
    
    [[NSWorkspace sharedWorkspace] openFile:xcodePrjPath withApplication:@"Xcode"];
}

- (IBAction)menuProjectSettings:(id)sender
{
    if (!projectSettings)
    {
        return;
    }

    ProjectSettingsWindowController *settingsWindowController = [[ProjectSettingsWindowController alloc] init];
    settingsWindowController.projectSettings = self.projectSettings;

    if ([settingsWindowController runModalSheetForWindow:window])
    {
        [self updateEverythingAfterSettingsChanged];
    }
}

- (void)updateEverythingAfterSettingsChanged
{
    [self.projectSettings store];
    [self updateResourcePathsFromProjectSettings];
    [CCBPublisherCacheCleaner cleanWithProjectSettings:projectSettings];
    [self reloadResources];
    [self setResolution:0];
    [_openPathsController updateMenuItemsForPackages];
}

- (IBAction) openDocument:(id)sender
{
    // Create the File Open Dialog
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];

    NSArray *allowedFileTypes = currentDocument
        ? @[@"spritebuilder", PACKAGE_NAME_SUFFIX]
        : @[@"spritebuilder"];
    [openDlg setAllowedFileTypes:allowedFileTypes];

    [openDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result)
    {
        if (result == NSOKButton)
        {
            NSArray* files = [openDlg URLs];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^
            {
                for (int i = 0; i < [files count]; i++)
                {
                    NSString *fileName = [[files objectAtIndex:i] path];
                    if ([fileName hasSuffix:PACKAGE_NAME_SUFFIX])
                    {
                        PackageImporter *packageImporter = [[PackageImporter alloc] init];
                        packageImporter.projectSettings = projectSettings;
                        [packageImporter importPackagesWithPaths:@[fileName] error:NULL];
                    }
                    else
                    {
                        [self openProject:fileName];
                    }
                }
            });
        }
    }];
}

- (IBAction) menuCloseProject:(id)sender
{
    [self closeProject];
}

- (IBAction)updateCocos2d:(id)sender
{
    Cocos2dUpdater *cocos2dUpdater = [[Cocos2dUpdater alloc] initWithAppDelegate:self projectSettings:projectSettings];
    [cocos2dUpdater updateAndBypassIgnore:YES];
}

-(void)updateLanguageHint
{
    switch (saveDlgLanguagePopup.selectedItem.tag)
    {
        case CCBProgrammingLanguageObjectiveC:
            saveDlgLanguageHint.title = @"All supported platforms";
            break;
        case CCBProgrammingLanguageSwift:
            saveDlgLanguageHint.title = @"iOS7+ and OSX 10.10+ only";
            break;
        default:
            NSAssert(false, @"Unknown programming language");
            saveDlgLanguageHint.title = @"";  // NOTREACHED
            break;
    }
}

-(void) createNewProjectTargetting:(CCBTargetEngine)engine
{
    // Accepted create document, prompt for place for file
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    [saveDlg setAllowedFileTypes:[NSArray arrayWithObject:@"spritebuilder"]];
    //saveDlg.message = @"Save your project file in the same directory as your projects resources.";

    // Configure the accessory view
    [saveDlg setAccessoryView:saveDlgAccessoryView];
    [saveDlgLanguagePopup removeAllItems];
    [saveDlgLanguagePopup addItemsWithTitles:@[@"Objective-C", @"Swift"]];
    ((NSMenuItem*)saveDlgLanguagePopup.itemArray.firstObject).tag = CCBProgrammingLanguageObjectiveC;
    ((NSMenuItem*)saveDlgLanguagePopup.itemArray.lastObject).tag = CCBProgrammingLanguageSwift;
    saveDlgLanguagePopup.target = self;
    saveDlgLanguagePopup.action = @selector(updateLanguageHint);
    [self updateLanguageHint];

    [saveDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            NSString* fileName = [[saveDlg URL] path];
            NSString* fileNameRaw = [fileName stringByDeletingPathExtension];
            
            [[UsageManager sharedManager] sendEvent:[NSString stringWithFormat:@"project_new_%@",saveDlgLanguagePopup.selectedItem.title]];
            
            // Check validity of file name
            NSCharacterSet* invalidChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
            if ([[fileNameRaw lastPathComponent] rangeOfCharacterFromSet:invalidChars].location == NSNotFound)
            {
                // Create directory
                [[NSFileManager defaultManager] createDirectoryAtPath:fileName withIntermediateDirectories:NO attributes:NULL error:NULL];
                
                // Set icon of created directory
                NSImage* folderIcon = [NSImage imageNamed:@"Folder.icns"];
                [[NSWorkspace sharedWorkspace] setIcon:folderIcon forFile:fileName options:0];
                
                // Create project file
                NSString* projectName = [fileNameRaw lastPathComponent];
                fileName = [[fileName stringByAppendingPathComponent:projectName] stringByAppendingPathExtension:@"ccbproj"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0),
                               dispatch_get_main_queue(), ^{
                                   CCBProjectCreator * creator = [[CCBProjectCreator alloc] init];
                                   if ([creator createDefaultProjectAtPath:fileName engine:engine programmingLanguage:saveDlgLanguagePopup.selectedItem.tag])
                                   {
                                       [self openProject:[fileNameRaw stringByAppendingPathExtension:@"spritebuilder"]];
                                   }
                                   else
                                   {
                                       [self modalDialogTitle:@"Failed to Create Project" message:@"Failed to create the project, make sure you are saving it to a writable directory."];
                                   }
                               });
            }
            else
            {
                [self modalDialogTitle:@"Failed to Create Project" message:@"Failed to create the project, make sure to only use letters and numbers for the file name (no spaces allowed)."];
            }
        }
    }];
}

- (IBAction) menuNewProject:(id)sender
{
	[self createNewProjectTargetting:CCBTargetEngineCocos2d];
}

-(IBAction) menuNewSpriteKitProject:(id)sender
{
	[self createNewProjectTargetting:CCBTargetEngineSpriteKit];
}

- (IBAction) menuNewPackage:(id)sender
{
    [_resourceCommandController newPackage:sender];
}

- (IBAction) newFolder:(id)sender
{
    [_resourceCommandController newFolder:nil];
}

- (IBAction) newDocument:(id)sender
{
    [_resourceCommandController newFile:nil];
}

- (IBAction) performClose:(id)sender
{
    if (!currentDocument) return;
    NSTabViewItem* item = [self tabViewItemFromDoc:currentDocument];
    if (!item) return;
    
    if ([self tabView:tabView shouldCloseTabViewItem:item])
    {
        [tabView removeTabViewItem:item];
    }
}

- (void) removedDocumentWithPath:(NSNotification *)notification
{
    NSString *path = [notification userInfo][@"filepath"];

    NSTabViewItem* item = [self tabViewItemFromPath:path includeViewWithinFolderPath:YES];
    if (item)
    {
        [tabView removeTabViewItem:item];
    }
}

- (void) renamedDocumentPathFrom:(NSString*)oldPath to:(NSString*)newPath
{
    NSTabViewItem* item = [self tabViewItemFromPath:oldPath includeViewWithinFolderPath:NO];
    CCBDocument* doc = [item identifier];
    doc.filePath = newPath;
    [item setLabel:doc.formattedName];
}

- (void)renamedResourcePathFrom:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSArray *items = [tabView tabViewItems];
   	for (NSUInteger i = 0; i < [items count]; i++)
   	{
   		CCBDocument *doc = [(NSTabViewItem *) [items objectAtIndex:i] identifier];
        if ([doc.filePath rangeOfString:fromPath].location != NSNotFound)
        {
            NSString *newFileName = [doc.filePath stringByReplacingOccurrencesOfString:fromPath withString:toPath];
            doc. filePath = newFileName;
        }
   	}
}

- (IBAction) menuSelectBehind:(id)sender
{
    [[CocosScene cocosScene] selectBehind];
}

- (IBAction) menuDeselect:(id)sender
{
    [self setSelectedNodes:NULL];
}

- (IBAction) undo:(id)sender
{
    if (!currentDocument) return;
    [currentDocument.undoManager undo];
    currentDocument.lastEditedProperty = NULL;
}

- (IBAction) redo:(id)sender
{
    if (!currentDocument) return;
    [currentDocument.undoManager redo];
    currentDocument.lastEditedProperty = NULL;
}

- (int) orientedDeviceTypeForSize:(CGSize)size
{
    for (int i = 1; i <= kCCBNumCanvasDevices; i++)
    {
        if (size.width == defaultCanvasSizes[i].width && size.height == defaultCanvasSizes[i].height) return i;
    }
    return 0;
}

- (void) updatePositionScaleFactor
{
    ResolutionSetting* res = [currentDocument.resolutions objectAtIndex:currentDocument.currentResolution];
    
    if (!res)
    {
        res = [[ResolutionSetting alloc] init];
        res.scale = 1;
    }
    
    CGFloat s = _baseContentScaleFactor * res.scale;
    
	if([CCDirector sharedDirector].contentScaleFactor != s)
    {
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        FNTConfigRemoveCache();
    }
    
    [CCDirector sharedDirector].contentScaleFactor = s;
    [CCDirector sharedDirector].UIScaleFactor = 1.0 / res.scale;
    [[CCFileUtils sharedFileUtils] setMacContentScaleFactor:res.scale];
				
    // Setup the rulers with the new contentScale
    [[CocosScene cocosScene].rulerLayer setup];
    [self updateDerivedViewScaleFactor];
}

- (void) setResolution:(int)r
{
    currentDocument.currentResolution = r;
    
    [self updatePositionScaleFactor];
    
    //
    // No need to call setStageSize here, since it gets called from reloadResources
    //
    //CocosScene* cs = [CocosScene cocosScene];
    //ResolutionSetting* resolution = [currentDocument.resolutions objectAtIndex:r];
    //[cs setStageSize:CGSizeMake(resolution.width, resolution.height) centeredOrigin:[cs centeredOrigin]];
    
    [self updateResolutionMenu];
    [self reloadResources];
    
    // Update size of root node
    //[PositionPropertySetter refreshAllPositions];
}

- (IBAction) menuEditResolutionSettings:(id)sender
{
    if (!currentDocument) return;
    
    ResolutionSetting* setting = [currentDocument.resolutions objectAtIndex:0];
    
    StageSizeWindow* wc = [[StageSizeWindow alloc] initWithWindowNibName:@"StageSizeWindow"];
    wc.wStage = setting.width;
    wc.hStage = setting.height;
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        [self saveUndoStateWillChangeProperty:@"*stageSize"];
        
        setting.width = wc.wStage;
        setting.height = wc.hStage;
        
        currentDocument.resolutions = [self updateResolutions:currentDocument.resolutions forDocDimensionType:kCCBDocDimensionsTypeLayer];
        [self updateResolutionMenu];
        [self setResolution:0];
    }
}

- (IBAction)menuResolution:(id)sender
{
    if (!currentDocument) return;
    
    [self setResolution:(int)[sender tag]];
    [self updateCanvasBorderMenu];
}

- (IBAction)menuEditCustomPropSettings:(id)sender
{
    if (!currentDocument) return;
    if (!self.selectedNode) return;
    
    NSString* customClass = [self.selectedNode extraPropForKey:@"customClass"];
    if (!customClass || [customClass isEqualToString:@""])
    {
        [self modalDialogTitle:@"Custom Class Needed" message:@"To add custom properties to a node you need to use a custom class."];
        return;
    }
    
    CustomPropSettingsWindow* wc = [[CustomPropSettingsWindow alloc] initWithWindowNibName:@"CustomPropSettingsWindow"];
    [wc copySettingsForNode:self.selectedNode];
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        [self saveUndoStateWillChangeProperty:@"*customPropSettings"];
        self.selectedNode.customProperties = wc.settings;
        [_inspectorController updateInspectorFromSelection];
    }
}

/*
- (void) updateStateOriginCenteredMenu
{
    CocosScene* cs = [CocosScene cocosScene];
    BOOL centered = [cs centeredOrigin];
    
    if (centered) [menuItemStageCentered setState:NSOnState];
    else [menuItemStageCentered setState:NSOffState];
}
 */

- (IBAction) menuSetStateOriginCentered:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    BOOL centered = ![cs centeredOrigin];
    
    [self saveUndoState];
    [cs setStageSize:[cs stageSize] centeredOrigin:centered];
    
    //[self updateStateOriginCenteredMenu];
}

- (void) updateCanvasBorderMenu
{
    CocosScene* cs = [CocosScene cocosScene];
    int tag = [cs stageBorder];
    [CCBUtil setSelectedSubmenuItemForMenu:menuCanvasBorder tag:tag];
}

- (void) updateWarningsButton
{
    [self updateWarningsOutline];
}

- (void) updateWarningsOutline
{
    [warningHandler updateWithWarnings:projectSettings.lastWarnings];
    [self.warningTableView reloadData];
}

- (IBAction) menuSetCanvasBorder:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    
    int tag = (int)[sender tag];
    [cs setStageBorder:tag];
}

- (void) updateCanvasColor
{
    CocosScene* cs = [CocosScene cocosScene];
    int color = currentDocument.stageColor;

    [cs setStageColor: color forDocDimensionsType: currentDocument.docDimensionsType];
    
    for (NSMenuItem *item in menuItemStageColor.submenu.itemArray)
    {
        item.state = NSOffState;
    }
    
    [menuItemStageColor.submenu itemWithTag: color].state = NSOnState;
}

- (IBAction) menuSetCanvasColor:(id)sender
{
    [self saveUndoStateWillChangeProperty:@"*stageColor"];
    currentDocument.stageColor = [sender tag];
    [self updateCanvasColor];
}

- (IBAction) menuZoomIn:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    
    float zoom = [cs stageZoom];
    zoom *= 1.2;
    if (zoom > 8) zoom = 8;
    [cs setStageZoom:zoom];
}

- (IBAction) menuZoomOut:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    
    float zoom = [cs stageZoom];
    zoom *= 1/1.2f;
    if (zoom < 0.125) zoom = 0.125f;
    [cs setStageZoom:zoom];
}

- (IBAction) menuResetView:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    cs.scrollOffset = ccp(0,0);
    [cs setStageZoom:1];
}

- (IBAction) pressedToolSelection:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    NSSegmentedControl* sc = sender;
    
    cs.currentTool = [sc selectedSegment];
}

- (int) uniqueSequenceIdFromSequences:(NSArray*) seqs
{
    int maxId = -1;
    for (SequencerSequence* seqCheck in seqs)
    {
        if (seqCheck.sequenceId > maxId) maxId = seqCheck.sequenceId;
    }
    return maxId + 1;
}

- (IBAction)menuTimelineSettings:(id)sender
{
    if (!currentDocument) return;
    
    SequencerSettingsWindow* wc = [[SequencerSettingsWindow alloc] initWithWindowNibName:@"SequencerSettingsWindow"];
    [wc copySequences:currentDocument.sequences];
    
    int success = [wc runModalSheetForWindow:window];
    
    if (success)
    {
        // Successfully updated timeline settings
        
        // Check for deleted timelines
        for (SequencerSequence* seq in currentDocument.sequences)
        {
            BOOL foundSeq = NO;
            for (SequencerSequence* newSeq in wc.sequences)
            {
                if (seq.sequenceId == newSeq.sequenceId)
                {
                    foundSeq = YES;
                    break;
                }
            }
            if (!foundSeq)
            {
                // Sequence deleted, remove from all nodes
                [sequenceHandler deleteSequenceId:seq.sequenceId];
            }
        }
        
        // Assign id:s to new sequences
        for (SequencerSequence* seq in wc.sequences)
        {
            if (seq.sequenceId == -1)
            {
                // Find a unique id
                seq.sequenceId = [self uniqueSequenceIdFromSequences:wc.sequences];
            }
        }
    
        // Update the timelines
        currentDocument.sequences = wc.sequences;
        sequenceHandler.currentSequence = [currentDocument.sequences objectAtIndex:0];

        [animationPlaybackManager stop];
    }
}

- (IBAction)menuTimelineNew:(id)sender
{
    if (!currentDocument) return;
    
    // Create new sequence and assign unique id
    SequencerSequence* newSeq = [[SequencerSequence alloc] init];
    newSeq.name = @"Untitled Timeline";
    newSeq.sequenceId = [self uniqueSequenceIdFromSequences:currentDocument.sequences];
    
    // Add it to list
    [currentDocument.sequences addObject:newSeq];
    
    // and set it to current
    sequenceHandler.currentSequence = newSeq;

    [animationPlaybackManager stop];
}

- (IBAction)menuTimelineDuplicate:(id)sender
{
    if (!currentDocument) return;
    
    // Duplicate current timeline
    int newSeqId = [self uniqueSequenceIdFromSequences:currentDocument.sequences];
    SequencerSequence* newSeq = [sequenceHandler.currentSequence duplicateWithNewId:newSeqId];
    
    // Add it to list
    [currentDocument.sequences addObject:newSeq];
    
    // and set it to current
    sequenceHandler.currentSequence = newSeq;

    [animationPlaybackManager stop];
}

- (IBAction)menuTimelineDuration:(id)sender
{
    if (!currentDocument) return;
    
    SequencerDurationWindow* wc = [[SequencerDurationWindow alloc] initWithWindowNibName:@"SequencerDurationWindow"];
    wc.duration = sequenceHandler.currentSequence.timelineLength;
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        [sequenceHandler deleteKeyframesForCurrentSequenceAfterTime:wc.duration];
        sequenceHandler.currentSequence.timelineLength = wc.duration;
        [_inspectorController updateInspectorFromSelection];
        [animationPlaybackManager stop];
    }
}

- (IBAction) menuOpenResourceManager:(id)sender
{
    //[resManagerPanel.window setIsVisible:![resManagerPanel.window isVisible]];
}

- (void) reloadResources
{
    if (!currentDocument) return;
    
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    FNTConfigRemoveCache();
    
    [self switchToDocument:currentDocument forceReload:YES];
    [sequenceHandler updatePropertiesToTimelinePosition];
}

- (IBAction) menuAlignToPixels:(id)sender
{
    if (!currentDocument) return;
    if (self.selectedNodes.count == 0) return;
    
    [self saveUndoStateWillChangeProperty:@"*align"];
    
    // Check if node can have children
    for (CCNode* c in self.selectedNodes)
    {
        if(c.locked)
            continue;
        
        CCPositionType positionType = [PositionPropertySetter positionTypeForNode:c prop:@"position"];
        if (positionType.xUnit != CCPositionUnitNormalized)
        {
            CGPoint pos = NSPointToCGPoint([PositionPropertySetter positionForNode:c prop:@"position"]);
            pos = ccp(roundf(pos.x), pos.y);
            [PositionPropertySetter setPosition:NSPointFromCGPoint(pos) forNode:c prop:@"position"];
            [PositionPropertySetter addPositionKeyframeForNode:c];
        }
        if (positionType.yUnit != CCPositionUnitNormalized)
        {
            CGPoint pos = NSPointToCGPoint([PositionPropertySetter positionForNode:c prop:@"position"]);
            pos = ccp(pos.x, roundf(pos.y));
            [PositionPropertySetter setPosition:NSPointFromCGPoint(pos) forNode:c prop:@"position"];
            [PositionPropertySetter addPositionKeyframeForNode:c];
        }
    }
    
    [_inspectorController refreshProperty:@"position"];
}

- (void) menuAlignObjectsCenter:(id)sender alignmentType:(int)alignmentType
{
    // Find position
    float alignmentValue = 0;
    
    for (CCNode* node in self.selectedNodes)
    {
        if (alignmentType == kCCBAlignHorizontalCenter)
        {
            alignmentValue += node.positionInPoints.x;
        }
        else if (alignmentType == kCCBAlignVerticalCenter)
        {
            alignmentValue += node.positionInPoints.y;
        }
    }
    alignmentValue = alignmentValue/self.selectedNodes.count;
    
    // Align objects
    for (CCNode* node in self.selectedNodes)
    {
        if(node.locked)
            continue;
        
        CGPoint newAbsPosition = node.positionInPoints;
        if (alignmentType == kCCBAlignHorizontalCenter)
        {
            newAbsPosition.x = alignmentValue;
        }
        else if (alignmentType == kCCBAlignVerticalCenter)
        {
            newAbsPosition.y = alignmentValue;
        }
        
        NSPoint newRelPos = [node convertPositionFromPoints:newAbsPosition type:node.positionType];
        
        //CCPositionType posType = [PositionPropertySetter positionTypeForNode:node prop:@"position"];
        //NSPoint newRelPos = [PositionPropertySetter calcRelativePositionFromAbsolute:NSPointFromCGPoint(newAbsPosition) type:posType parentSize:node.parent.contentSize];
        
        [PositionPropertySetter setPosition:newRelPos forNode:node prop:@"position"];
        [PositionPropertySetter addPositionKeyframeForNode:node];
    }
}

- (void) menuAlignObjectsEdge:(id)sender alignmentType:(int)alignmentType
{
    CGFloat x;
    CGFloat y;
    
    int nAnchor = self.selectedNodes.count - 1;
    CCNode* nodeAnchor = [self.selectedNodes objectAtIndex:nAnchor];
    
    for (int i = 0; i < self.selectedNodes.count - 1; ++i)
    {
        CCNode* node = [self.selectedNodes objectAtIndex:i];
        
        if(node.locked)
            continue;
        
        CGPoint newAbsPosition = node.position;
        
        switch (alignmentType)
        {
            case kCCBAlignLeft:
                x = nodeAnchor.positionInPoints.x
                - nodeAnchor.contentSize.width * nodeAnchor.scaleX * nodeAnchor.anchorPoint.x;
                
                newAbsPosition.x = x
                + node.contentSize.width * node.scaleX * node.anchorPoint.x;
                break;
            case kCCBAlignRight:
                x = nodeAnchor.positionInPoints.x
                + nodeAnchor.contentSize.width * nodeAnchor.scaleX * nodeAnchor.anchorPoint.x;
                
                newAbsPosition.x = x
                - node.contentSize.width * node.scaleX * node.anchorPoint.x;
                break;
            case kCCBAlignTop:
                y = nodeAnchor.positionInPoints.y
                + nodeAnchor.contentSize.height * nodeAnchor.scaleY * nodeAnchor.anchorPoint.y;
                
                newAbsPosition.y = y
                - node.contentSize.height * node.scaleY * node.anchorPoint.y;
                break;
            case kCCBAlignBottom:
                y = nodeAnchor.positionInPoints.y
                - nodeAnchor.contentSize.height * nodeAnchor.scaleY * nodeAnchor.anchorPoint.y;
                
                newAbsPosition.y = y
                + node.contentSize.height * node.scaleY * node.anchorPoint.y;
                break;
        }
        
        //CCPositionType posType = [PositionPropertySetter positionTypeForNode:node prop:@"position"];
        //NSPoint newRelPos = [PositionPropertySetter calcRelativePositionFromAbsolute:NSPointFromCGPoint(newAbsPosition) type:posType parentSize:node.parent.contentSize];
        
        NSPoint newRelPos = [node convertPositionFromPoints:newAbsPosition type:node.positionType];
        
        [PositionPropertySetter setPosition:newRelPos forNode:node prop:@"position"];
        [PositionPropertySetter addPositionKeyframeForNode:node];
    }
 }

- (void) menuAlignObjectsAcross:(id)sender alignmentType:(int)alignmentType
{
    CGFloat x;
    CGFloat cxNode;
    CGFloat xMin;
    CGFloat xMax;
    CGFloat cxTotal;
    CGFloat cxInterval;
    
    if (self.selectedNodes.count < 3)
        return;
    
    cxTotal = 0.0f;
    xMin = FLT_MAX;
    xMax = FLT_MIN;
    
    for (int i = 0; i < self.selectedNodes.count; ++i)
    {
        CCNode* node = [self.selectedNodes objectAtIndex:i];
        

        
        cxNode = node.contentSize.width * node.scaleX;
        
        x = node.positionInPoints.x - cxNode * node.anchorPoint.x;
        
        if (xMin > x)
            xMin = x;
        
        if (xMax < x + cxNode)
            xMax = x + cxNode;
        
        cxTotal += cxNode;
    }
    
    cxInterval = (xMax - xMin - cxTotal) / (self.selectedNodes.count - 1);
    
    x = xMin;
    
    NSArray* sortedNodes = [self.selectedNodes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CCNode* lhs = obj1;
        CCNode* rhs = obj2;
        if (lhs.positionInPoints.x < rhs.position.x)
            return NSOrderedAscending;
        if (lhs.positionInPoints.x > rhs.position.x)
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
    
    for (int i = 0; i < self.selectedNodes.count; ++i)
    {
        CCNode* node = [sortedNodes objectAtIndex:i];
        
        if(node.locked)
            continue;
        
        CGPoint newAbsPosition = node.positionInPoints;
        
        cxNode = node.contentSize.width * node.scaleX;
        
        newAbsPosition.x = x + cxNode * node.anchorPoint.x;
        
        x = x + cxNode + cxInterval;
        
        //int posType = [PositionPropertySetter positionTypeForNode:node prop:@"position"];
        //NSPoint newRelPos = [PositionPropertySetter calcRelativePositionFromAbsolute:NSPointFromCGPoint(newAbsPosition) type:posType parentSize:node.parent.contentSize];
        NSPoint newRelPos = [node convertPositionFromPoints:newAbsPosition type:node.positionType];
        
        [PositionPropertySetter setPosition:newRelPos forNode:node prop:@"position"];
        [PositionPropertySetter addPositionKeyframeForNode:node];
    }
}


- (void) menuAlignObjectsDown:(id)sender alignmentType:(int)alignmentType
{
    CGFloat y;
    CGFloat cyNode;
    CGFloat yMin;
    CGFloat yMax;
    CGFloat cyTotal;
    CGFloat cyInterval;
    
    if (self.selectedNodes.count < 3)
        return;
    
    cyTotal = 0.0f;
    yMin = FLT_MAX;
    yMax = FLT_MIN;
    
    for (int i = 0; i < self.selectedNodes.count; ++i)
    {
        CCNode* node = [self.selectedNodes objectAtIndex:i];
        
        if(node.locked)
            continue;
        
        cyNode = node.contentSize.height * node.scaleY;
        
        y = node.positionInPoints.y - cyNode * node.anchorPoint.y;
        
        if (yMin > y)
            yMin = y;
        
        if (yMax < y + cyNode)
            yMax = y + cyNode;
        
        cyTotal += cyNode;
    }
    
    cyInterval = (yMax - yMin - cyTotal) / (self.selectedNodes.count - 1);
    
    y = yMin;
    
    NSArray* sortedNodes = [self.selectedNodes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CCNode* lhs = obj1;
        CCNode* rhs = obj2;
        if (lhs.position.y < rhs.position.y)
            return NSOrderedAscending;
        if (lhs.position.y > rhs.position.y)
            return NSOrderedDescending;
        return NSOrderedSame;
    }];

    for (int i = 0; i < self.selectedNodes.count; ++i)
    {
        CCNode* node = [sortedNodes objectAtIndex:i];
        
        CGPoint newAbsPosition = node.positionInPoints;
        
        cyNode = node.contentSize.height * node.scaleY;
        
        newAbsPosition.y = y + cyNode * node.anchorPoint.y;
        
        y = y + cyNode + cyInterval;
        
        //int posType = [PositionPropertySetter positionTypeForNode:node prop:@"position"];
        //NSPoint newRelPos = [PositionPropertySetter calcRelativePositionFromAbsolute:NSPointFromCGPoint(newAbsPosition) type:posType parentSize:node.parent.contentSize];
        NSPoint newRelPos = [node convertPositionFromPoints:newAbsPosition type:node.positionType];
        
        [PositionPropertySetter setPosition:newRelPos forNode:node prop:@"position"];
        [PositionPropertySetter addPositionKeyframeForNode:node];
    }
}

- (void) menuAlignObjectsSize:(id)sender alignmentType:(int)alignmentType
{
    /*
    CGFloat x;
    CGFloat y;
    
    int nAnchor = self.selectedNodes.count - 1;
    CCNode* nodeAnchor = [self.selectedNodes objectAtIndex:nAnchor];
 
    for (int i = 0; i < self.selectedNodes.count - 1; ++i)
    {
        CCNode* node = [self.selectedNodes objectAtIndex:i];
        
        switch (alignmentType)
        {
            case kCCBAlignSameWidth:
                x = nodeAnchor.contentSize.width * nodeAnchor.scaleX;
                if (abs(x) >= 0.0001f)
                    x /= node.contentSize.width;
                y = node.scaleY;
                break;
            case kCCBAlignSameHeight:
                x = node.scaleX;
                y = nodeAnchor.contentSize.height * nodeAnchor.scaleY;
                if (abs(y) >= 0.0001f)
                    y /= node.contentSize.height;
                break;
            case kCCBAlignSameSize:
                x = nodeAnchor.contentSize.width * nodeAnchor.scaleX;
                if (abs(x) >= 0.0001f)
                    x /= node.contentSize.width;
                y = nodeAnchor.contentSize.height * nodeAnchor.scaleY;
                if (abs(y) >= 0.0001f)
                    y /= node.contentSize.height;
                break;
        }

        int posType = [PositionPropertySetter positionTypeForNode:node prop:@"scale"];
        
        [PositionPropertySetter setScaledX:x Y:y type:posType forNode:node prop:@"scale"];
        [PositionPropertySetter addPositionKeyframeForNode:node];
    }
     */
}


- (IBAction) menuAlignObjects:(id)sender
{
    if (!currentDocument)
        return;
    
    if (self.selectedNodes.count <= 1)
        return;
    
    [self saveUndoStateWillChangeProperty:@"*align"];
    
    int alignmentType = [sender tag];
    
    switch (alignmentType)
    {
        case kCCBAlignHorizontalCenter:
        case kCCBAlignVerticalCenter:
            [self menuAlignObjectsCenter:sender alignmentType:alignmentType];
            break;
        case kCCBAlignLeft:
        case kCCBAlignRight:
        case kCCBAlignTop:
        case kCCBAlignBottom:
            [self menuAlignObjectsEdge:sender alignmentType:alignmentType];
            break;
        case kCCBAlignAcross:
            [self menuAlignObjectsAcross:sender alignmentType:alignmentType];
            break;
        case kCCBAlignDown:
            [self menuAlignObjectsDown:sender alignmentType:alignmentType];
            break;
        case kCCBAlignSameSize:
        case kCCBAlignSameWidth:
        case kCCBAlignSameHeight:
            [self menuAlignObjectsSize:sender alignmentType:alignmentType];
            break;
    }
}


- (IBAction)menuArrange:(id)sender
{
    int type = [sender tag];
    
    CCNode* node = self.selectedNode;
    CCNode* parent = node.parent;
    NSArray* siblings = [node.parent children];
    
    // Check bounds
    if ((type == kCCBArrangeSendToBack || type == kCCBArrangeSendBackward)
        && node.zOrder == 0)
    {
        NSBeep();
        return;
    }
    
    if ((type == kCCBArrangeBringToFront || type == kCCBArrangeBringForward)
        && node.zOrder == siblings.count - 1)
    {
        NSBeep();
        return;
    }
    
    if (siblings.count < 2)
    {
        NSBeep();
        return;
    }
    
    int newIndex = 0;
    
    // Bring forward / send backward
    if (type == kCCBArrangeSendToBack)
    {
        newIndex = 0;
    }
    else if (type == kCCBArrangeBringToFront)
    {
        newIndex = siblings.count -1;
    }
    else if (type == kCCBArrangeSendBackward)
    {
        newIndex = node.zOrder - 1;
    }
    else if (type == kCCBArrangeBringForward)
    {
        newIndex = node.zOrder + 1;
    }

    // Note: Deleting the node will cleanup the userObject containting the NodeInfo stuff
    // This needs to be preserved and attached again.
    id userObject = node.userObject;
    [self deleteNode:node];
    node.userObject = userObject;

    [self addCCObject:node toParent:parent atIndex:newIndex];
}

- (IBAction)menuSetEasing:(id)sender
{
    int easingType = [sender tag];
    [sequenceHandler setContextKeyframeEasingType:easingType];
    [sequenceHandler updatePropertiesToTimelinePosition];
}

- (IBAction)menuSetEasingOption:(id)sender
{
    if (!currentDocument) return;
    
    float opt = [sequenceHandler.contextKeyframe.easing.options floatValue];
    
    
    SequencerKeyframeEasingWindow* wc = [[SequencerKeyframeEasingWindow alloc] initWithWindowNibName:@"SequencerKeyframeEasingWindow"];
    wc.option = opt;
    
    int type = sequenceHandler.contextKeyframe.easing.type;
    if (type == kCCBKeyframeEasingCubicIn
        || type == kCCBKeyframeEasingCubicOut
        || type == kCCBKeyframeEasingCubicInOut)
    {
        wc.optionName = @"Rate:";
    }
    else if (type == kCCBKeyframeEasingElasticIn
             || type == kCCBKeyframeEasingElasticOut
             || type == kCCBKeyframeEasingElasticInOut)
    {
        wc.optionName = @"Period:";
    }
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        float newOpt = wc.option;
        
        if (newOpt != opt)
        {
            [self saveUndoStateWillChangeProperty:@"*keyframeeasingoption"];
            sequenceHandler.contextKeyframe.easing.options = [NSNumber numberWithFloat:wc.option];
            [sequenceHandler updatePropertiesToTimelinePosition];
        }
    }
}

- (IBAction)menuCreateKeyframesFromSelection:(id)sender
{
    [_resourceCommandController createKeyFrameFromSelection:nil];
}

- (IBAction)menuNewFolder:(NSMenuItem*)sender
{
    ResourceManagerOutlineView * resManagerOutlineView = (ResourceManagerOutlineView*)outlineProject;
    sender.tag = resManagerOutlineView.selectedRow;
    
    [self newFolder:sender];
}

- (IBAction)menuNewFile:(NSMenuItem*)sender
{
    ResourceManagerOutlineView * resManagerOutlineView = (ResourceManagerOutlineView*)outlineProject;
    sender.tag = resManagerOutlineView.selectedRow;
    
    [self newDocument:sender];
}

- (IBAction)menuAlignKeyframeToMarker:(id)sender
{
    [SequencerUtil alignKeyframesToMarker];
}

- (IBAction)menuStretchSelectedKeyframes:(id)sender
{
    SequencerStretchWindow* wc = [[SequencerStretchWindow alloc] initWithWindowNibName:@"SequencerStretchWindow"];
    wc.factor = 1;
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        [SequencerUtil stretchSelectedKeyframes:wc.factor];
    }
}

- (IBAction)menuReverseSelectedKeyframes:(id)sender
{
    [SequencerUtil reverseSelectedKeyframes];
}

- (IBAction)menuAddStickyNote:(id)sender
{
    CocosScene* cs = [CocosScene cocosScene];
    [cs setStageZoom:1];
    self.showStickyNotes = YES;
    [cs.notesLayer addNote];
}

- (NSString*) keyframePropNameFromTag:(int)tag
{
    if      (tag == 0) return @"visible";
    else if (tag == 1) return @"position";
    else if (tag == 2) return @"scale";
    else if (tag == 3) return @"rotation";
    else if (tag == 4) return @"spriteFrame";
    else if (tag == 5) return @"opacity";
    else if (tag == 6) return @"color";
    else if (tag == 7) return @"skew";
    else return NULL;
}

- (IBAction)menuAddKeyframe:(id)sender
{
    int tag = [sender tag];
    [sequenceHandler menuAddKeyframeNamed:[self keyframePropNameFromTag:tag]];
}

- (IBAction)menuCutKeyframe:(id)sender
{
    [self cut:sender];
}

- (IBAction)menuCopyKeyframe:(id)sender
{
    [self copy:sender];
}

- (IBAction)menuPasteKeyframes:(id)sender
{
    [self paste:sender];
}

- (IBAction)menuDeleteKeyframe:(id)sender
{
    [self cut:sender];
}

- (IBAction)menuJavaScriptControlled:(id)sender
{
    [self saveUndoStateWillChangeProperty:@"*javascriptcontrolled"];
    
    jsControlled = !jsControlled;
    [_inspectorController updateInspectorFromSelection];
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.action == @selector(saveDocument:)) return hasOpenedDocument;
    else if (menuItem.action == @selector(saveDocumentAs:)) return hasOpenedDocument;
    else if (menuItem.action == @selector(saveAllDocuments:)) return hasOpenedDocument;
    else if (menuItem.action == @selector(performClose:)) return hasOpenedDocument;
    else if (menuItem.action == @selector(menuCreateKeyframesFromSelection:))
    {
        return (hasOpenedDocument && [SequencerUtil canCreateFramesFromSelectedResources]);
    }
    else if (menuItem.action == @selector(menuAlignKeyframeToMarker:))
    {
        return (hasOpenedDocument && [SequencerUtil canAlignKeyframesToMarker]);
    }
    else if (menuItem.action == @selector(menuStretchSelectedKeyframes:))
    {
        return (hasOpenedDocument && [SequencerUtil canStretchSelectedKeyframes]);
    }
    else if (menuItem.action == @selector(menuReverseSelectedKeyframes:))
    {
        return (hasOpenedDocument && [SequencerUtil canReverseSelectedKeyframes]);
    }
    else if (menuItem.action == @selector(menuAddKeyframe:))
    {
        if (!hasOpenedDocument) return NO;
        if (!self.selectedNode) return NO;
        return [sequenceHandler canInsertKeyframeNamed:[self keyframePropNameFromTag:menuItem.tag]];
    }
    else if (menuItem.action == @selector(menuSetCanvasBorder:))
    {
        if (!hasOpenedDocument) return NO;
        int tag = [menuItem tag];
        if (tag == kCCBBorderNone) return YES;
        CGSize canvasSize = [[CocosScene cocosScene] stageSize];
        if (canvasSize.width == 0 || canvasSize.height == 0) return NO;
        return YES;
    }
    else if (menuItem.action == @selector(menuArrange:))
    {
        if (!hasOpenedDocument) return NO;
        return (self.selectedNode != NULL);
    }
    
    return YES;
}

- (IBAction)menuAbout:(id)sender
{
    if(!aboutWindow)
    {
        aboutWindow = [[AboutWindow alloc] initWithWindowNibName:@"AboutWindow"];
    }
    
    [[aboutWindow window] makeKeyAndOrderFront:self];
}

- (IBAction) openRegistrationWindow:(id)sender
{
	[self openRegistration];
}
	
	
-(BOOL)openRegistration
{
    if (!registrationWindow)
    {
        registrationWindow = [[MailingListWindow alloc] initWithWindowNibName:@"MailingListWindow"];
    }
    
	NSInteger result = [NSApp runModalForWindow: registrationWindow.window];
	[NSApp endSheet:registrationWindow.window];
	[registrationWindow.window close];
	
	if(result == NSModalResponseStop)
	{
		return YES;
	}

	return NO;
}

- (NSUndoManager*) windowWillReturnUndoManager:(NSWindow *)window
{
    return currentDocument.undoManager;
}

-(NSString*)applicationTitle
{
	return @"SpriteBuilder";
}

#pragma mark Sparkle

-(void)setupSparkleGui
{
#if SB_SANDBOXED
	[self.menuCheckForUpdates setHidden:YES];
#endif
}

- (SBVersionComparitor*)versionComparatorForUpdater
{
	return [SBVersionComparitor new];
}

- (BOOL)updaterShouldPromptForPermissionToCheckForUpdates
{
#if TESTING || SB_SANDBOXED
	return NO;
#else 
	return YES;
#endif
}

- (NSString *)feedURLStringForUpdater:(id)updater
{
	return @"http://update.spritebuilder.com";
}

#pragma mark Extras / Snap

- (void)setupExtras
{
    // Default Extras
    self.showExtras      = YES;
    self.showGuides      = YES;
    self.showGuideGrid   = NO;
    self.showStickyNotes = YES;
    
    // Default Snap
    self.snapToggle      = YES;
    self.snapToGuides    = YES;
    self.snapGrid        = NO;
    self.snapNode        = YES;
}

-(void) setShowGuides:(BOOL)showGuidesNew {
    showGuides = showGuidesNew;
    [[[CocosScene cocosScene] guideLayer] updateGuides];
}

-(void) setShowGuideGrid:(BOOL)showGuideGridNew {
    showGuideGrid = showGuideGridNew;
    if(showGuideGrid) {
        [self setSnapGrid:YES];
    }
    [[[CocosScene cocosScene] guideLayer] updateGuides];
}

- (IBAction) menuGuideGridSettings:(id)sender
{
    if (!currentDocument) return;

    GuideGridSizeWindow* wc = [[GuideGridSizeWindow alloc] initWithWindowNibName:@"GuideGridSizeWindow"];
    
    wc.wStage = [[[CocosScene cocosScene] guideLayer] gridSize].width;
    wc.hStage = [[[CocosScene cocosScene] guideLayer] gridSize].height;
    
    int success = [wc runModalSheetForWindow:window];
    if (success)
    {
        CGSize newSize = CGSizeMake(wc.wStage,wc.hStage);
        
        [[[CocosScene cocosScene] guideLayer] setGridSize:newSize];
        [[[CocosScene cocosScene] guideLayer] buildGuideGrid];
        [[[CocosScene cocosScene] guideLayer] updateGuides];
    }
}

- (void)setCurrentDocument:(CCBDocument *)aCurrentDocument
{
    currentDocument = aCurrentDocument;
    animationPlaybackManager.enabled = aCurrentDocument != nil;
}

#pragma mark Delegate methods

- (void)windowDidChangeScreen:(NSNotification *)notification {
    if (window == notification.object) {
        CCDirectorMac *dir = (CCDirectorMac *)[CCDirector sharedDirector];

        // check if DPI has changed
        if (dir.deviceContentScaleFactor != _baseContentScaleFactor) {
            
            _baseContentScaleFactor = dir.deviceContentScaleFactor;
            CGFloat tmp = dir.contentScaleFactor;
            dir.contentScaleFactor = _baseContentScaleFactor;
            CGSize realSize = CGSizeMake(cocosView.frame.size.width * _baseContentScaleFactor, cocosView.frame.size.height * _baseContentScaleFactor);
            [[CCDirector sharedDirector] reshapeProjection:realSize];
            dir.contentScaleFactor = tmp;
            
            [self updatePositionScaleFactor];
        }
    }
}

- (BOOL) windowShouldClose:(id)sender
{
    if ([self hasDirtyDocument])
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Quit SpriteBuilder"
                                         defaultButton:@"Cancel"
                                       alternateButton:@"Quit"
                                           otherButton:@"Save All & Quit"
                             informativeTextWithFormat:@"There are unsaved documents. If you quit now you will lose any changes you have made."];

        [alert setAlertStyle:NSWarningAlertStyle];
        NSInteger result = [alert runModal];

        if (result == NSAlertOtherReturn)
        {
            [self saveAllDocuments:nil];
            return YES;
        }

        if (result == NSAlertDefaultReturn)
        {
            return NO;
        }
    }
    return YES;
}

- (void) windowWillClose:(NSNotification *)notification
{
    [window saveMainWindowPanelsVisibility];

    [self saveOpenProjectPathToDefaults];

    [[NSApplication sharedApplication] terminate:self];
}

- (void)saveOpenProjectPathToDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *projectPath = @"";
    if (projectSettings) {
		projectPath = projectSettings.projectPath;
		projectPath = [projectPath stringByDeletingLastPathComponent];
        [defaults setObject:projectPath forKey:LAST_OPENED_PROJECT_PATH];
	}
    else
    {
        [defaults removeObjectForKey:LAST_OPENED_PROJECT_PATH];
    }
    [defaults synchronize];
}

- (NSSize) windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
    static float minWidth = 1060.0f;
    static float minHeight = 500.0f;
    [splitHorizontalView setNeedsLayout:YES];
    return NSSizeFromCGSize(
                CGSizeMake(
                        frameSize.width<minWidth ? minWidth:frameSize.width,
                        frameSize.height<minHeight ? minHeight:frameSize.height)
    );
}

- (IBAction) menuQuit:(id)sender
{
    if ([self windowShouldClose:self])
    {
		[self.projectSettings store];
        [[NSApplication sharedApplication] terminate:self];
    }
}

-(BOOL)showHelpDialog:(NSString*)type
{
	NSDictionary * helpDialogs = [[NSUserDefaults standardUserDefaults] objectForKey:@"HelpDialogs"];
	if(helpDialogs == nil || !helpDialogs[type])
		return YES;
	
	//Its presence indicates we don't show the dialog.
	return NO;
			
}
-(void)disableHelpDialog:(NSString*)type
{
	NSMutableDictionary * helpDialogs = [NSMutableDictionary dictionary];
	
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"HelpDialogs"])
	{
		NSDictionary * temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"HelpDialogs"];
		helpDialogs = [NSMutableDictionary dictionaryWithDictionary:temp];
	}
	
	helpDialogs[type] = @(NO);
	[[NSUserDefaults standardUserDefaults] setObject:helpDialogs forKey:@"HelpDialogs"];
}

- (IBAction)showHelp:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://makegameswith.us/docs/"]];
}

- (IBAction)showAPIDocs:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.cocos2d-swift.org/docs/api/index.html"]];
}

- (IBAction)reportBug:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/apportable/SpriteBuilder/issues"]];
}
- (IBAction)menuHiddenNode:(id)sender {
}

- (IBAction)visitCommunity:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://forum.spritebuilder.com"]];
}

#pragma mark Debug

- (IBAction) debug:(id)sender
{
    NSLog(@"DEBUG");
    
    [[ResourceManager sharedManager] debugPrintDirectories];
}

- (NSString*)getPathOfMenuItem:(NSMenuItem*)item
{
    NSOutlineView* outlineView = [AppDelegate appDelegate].outlineProject;
    NSUInteger idx = [item tag];
	
	NSString * fullpath;
	
	id row = [outlineView itemAtRow:idx];
	if([row isKindOfClass:[RMDirectory class]])
	{
		fullpath = [row dirPath];
	}
	else if([row isKindOfClass:[RMResource class]])
	{
		fullpath = [row filePath];
	}

    
    // if it doesn't exist, peek inside "resources-auto" (only needed in the case of resources, which has a different visual
    // layout than what is actually on the disk).
    // Should probably be removed and pulled into [RMResource filePath]
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullpath] == NO)
    {
        NSString* filename = [fullpath lastPathComponent];
        NSString* directory = [fullpath stringByDeletingLastPathComponent];
        fullpath = [NSString pathWithComponents:[NSArray arrayWithObjects:directory, @"resources-auto", filename, nil]];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullpath] == NO) {
        return nil;
    }
    
    return fullpath;
}


@end
