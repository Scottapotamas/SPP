//
//  SPP.mm
//  GAMMA
//
//  Created by Scott Rapson on 17/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SPP.h"

@implementation SPP

+(id) SPPstandardLevelSelectofStage:(int)stage padding:(CGPoint)pad {
	return [[[self alloc] initWithLevelSelectofStage:(int)stage padding:(CGPoint)pad] autorelease];
}

-(id) initWithLevelSelectofStage:(int)stage padding:(CGPoint)pad {
    if ((self = [super init]))	{
        
        screenSize = [CCDirector sharedDirector].winSize;
        stageBeingBuilt = stage;
        padding = pad;
        
        //Load the data singletons for both the static level data plist, and the users one, so we can get titles, scores etc
        levelData = [Config instanceForFile:[Utils pathForFileInBundle:[NSString stringWithFormat:@"GameDataStage%i.plist", stageBeingBuilt]]];
        userData = [Config instanceForFile:[Utils pathForFileInLibrary:[NSString stringWithFormat:@"UserDataStage%i.plist", stageBeingBuilt]]];

        [self buildTitleText];
        [self buildGameCenter];
        [self buildLevelButtons];
    }
    return self;

}

-(void) buildTitleText {
        
    NSString *titletoshow = [levelData get:[NSString stringWithFormat:@"/StageTitle"]];
    CCLabelTTF *stageTitle = [CCLabelTTF labelWithString:titletoshow fontName:kMainFont fontSize:kFontSizeLarge];
    stageTitle.position =  ccp( screenSize.width/2, 285);
    [self addChild:stageTitle];
}

-(void) buildGameCenter {

    //make label, button which go to stage's leaderboard. (leaderboards are cumulative per stage due GC 25 lb limit)
    NSString *scoretoshow = [userData get:[NSString stringWithFormat:@"/StageScore"]];
    CCLabelTTF *stageScore = [CCLabelTTF labelWithString:scoretoshow fontName:kMainFont fontSize:kFontSizeMediumSmall];
    stageScore.position =  ccp(screenSize.width/2, 50);
    [self addChild:stageScore];
    
    //The CG button
    CCMenuItem *leaderboardButton   = [CCMenuItemImage 
                                       itemFromNormalImage:@"gameButton.png" 
                                       selectedImage:@"gameButtonPressed.png" 
                                       target:self 
                                       selector:@selector(buttonAction:)];
    leaderboardButton.position      = ccp(380, 50);
    [leaderboardButton setTag:-1];       //set the tag, which we use to load the correct function.

    CCMenu *GCMenu = [CCMenu menuWithItems:leaderboardButton, nil];
    GCMenu.position = CGPointZero;
    [self addChild:GCMenu];
}

-(void) buildLevelButtons {
    int cols = 2, rows = 2; //desired dimensions
    int row = 0, col = 0;   //item is on row... col ...
    int levelBeingBuilt;
    
    NSMutableArray *menuItemsonPage = [[NSMutableArray alloc] init];
    
    for (levelBeingBuilt=1; levelBeingBuilt<5; levelBeingBuilt++) {
        
        CCLOG(@"MenuButton being Built: %i", levelBeingBuilt);

        NSString *stagelevel = [NSString stringWithFormat:@"%i%i", stageBeingBuilt, levelBeingBuilt];
        NSString *normalsprite = [NSString stringWithFormat:@"level%@.png", stagelevel];
        NSString *selectedsprite = [NSString stringWithFormat:@"level%@Pressed.png", stagelevel];
        NSString *lockedsprite = [NSString stringWithFormat:@"level%@Locked.png", stagelevel];
        
        CCMenuItem *menuItem = [CCMenuItemImage itemFromNormalImage:normalsprite 
                                                       selectedImage:selectedsprite 
                                                       disabledImage:lockedsprite 
                                                              target:self 
                                                            selector:@selector(theGame:)];
    
        menuItem.position = CGPointMake(self.position.x + col * padding.x + 150, self.position.y - row * padding.y + 210);
        
        // Increment our positions for the next item(s).
		++col;
		if (col == cols) {
			col = 0;    //We have filled our quota of columns. Start doing the next row.
			++row;
			
			if( row == rows ) {
				col = 0;
				row = 0;
			}
        }
        
        [menuItem setTag:[stagelevel intValue]];
        [menuItemsonPage addObject:menuItem];
    }
    
    CCMenu *stageMenu = [CCMenu menuWithItems: nil];    //Make the menu empty, then add each of the items to it afterward.
    stageMenu.position = CGPointZero;
    [self addChild:stageMenu];   
                         
    for (id menuItem in menuItemsonPage)  
        [stageMenu addChild:menuItem];
    
    [menuItemsonPage release];    
    
    //[page1Menu setIsEnabled:NO];
    //http://www.cocos2d-iphone.org/forum/topic/1059
}

-(void)theGame:(CCMenuItem*)itemPassedIn {
    CCLOG(@"PlayIt:%i", [itemPassedIn tag]);
    [[levelselScrollerLayer sharedlevelselScrollerLayer] playGame:[itemPassedIn tag]];
    
}

-(void)buttonAction:(CCMenuItem*)itemPassedIn {

    //used to run the function we need from that button. Easily expandable if required.
    
    if ([itemPassedIn tag] == -1) { //gamecentre show leaderboard button
        NSString *leaderboardtoShow = [NSString stringWithFormat:@"Stage%iID", stageBeingBuilt];
        [[DDGameKitHelper sharedGameKitHelper] showLeaderboardwithCategory:leaderboardtoShow timeScope:GKLeaderboardTimeScopeAllTime];
    }
}


-(void) dealloc {
    stageBeingBuilt = nil;
    [Config removeInstance:levelData]; 
    [Config removeInstance:userData]; 
    [super dealloc];
}

@end
