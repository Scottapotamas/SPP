//
//  SPP.h
//  GAMMA
//
/*
 SPP, Simpe Page Populator
 
 Takes in imputs, and returns a CCLayer with a title, buttons and other text. 
 Designed to make menu making for GAMMA much faster, with less copy/paste
 
 
 */

#import "cocos2d.h"
#import "Config.h"
#import "Constants.h"
#import "levelselScrollerLayer.h"

@interface SPP : CCLayer {
    CGSize screenSize;
    CGPoint padding;
    Config *levelData;
    Config *userData;
    
    int stageBeingBuilt;

}


+(id) SPPstandardLevelSelectofStage:(int)stage padding:(CGPoint)pad;
-(id) initWithLevelSelectofStage:(int)stage padding:(CGPoint)pad;

-(void) buildTitleText;
-(void) buildGameCenter;
-(void) buildLevelButtons;
-(void) theGame:(CCMenuItem*)itemPassedIn;

@end
