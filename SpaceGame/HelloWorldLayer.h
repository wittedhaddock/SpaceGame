//
//  HelloWorldLayer.h
//  SpaceGame
//
//  Created by Local Administrator on 6/21/13.
//  Copyright James Graham 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
typedef enum{
    kEndReasonWin,
    kEndReasonLose
} EndReason;

@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    CCSpriteBatchNode *_batchNode;
    CCSprite *_ship;
    CCParallaxNode *_backgroundNode;
    CCSprite *_spaceDust1;
    CCSprite *_spaceDust2;
    CCSprite *_planetSunrise;
    CCSprite *_galaxy;
    CCSprite *_spacialAnomaly;
    CCSprite *_spacialAnomaly2;
    float _shipPointsPerSecY;
    CCArray *_asteroids;
    int _nextAsteroid;
    double _nextAsteroidSpawn;
    CCArray *_shipLasers;
    int _nextShipLaser;
    int _lives;
    double _gameOverTime;
    bool _gameOver;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
