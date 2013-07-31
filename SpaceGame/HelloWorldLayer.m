//
//  HelloWorldLayer.m
//  SpaceGame
//
//  Created by Local Administrator on 6/21/13.
//  Copyright James Graham 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCParallaxNode-Extras.h"
#pragma mark - HelloWorldLayer
#define asteroidNumber 25
#define shipLasers 5
// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init])) {
        _backgroundNode = [CCParallaxNode node];
        [self addChild:_backgroundNode z:-1];
        CGSize windowSize = [CCDirector sharedDirector].winSize;

  
        
		_batchNode = [CCSpriteBatchNode batchNodeWithFile:@"Sprites.pvr.ccz"];
        
        [self addChild:_batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Sprites.plist"];
        
        _ship = [CCSprite spriteWithSpriteFrameName:@"SpaceFlier_sm_1.png"];
        _ship.position = ccp(windowSize.width *0.1, windowSize.height*0.5);
        [_batchNode addChild:_ship z:1];
        
        _spaceDust1 = [CCSprite spriteWithFile:@"bg_front_spacedust.png"];
        _spaceDust2 = [CCSprite spriteWithFile:@"bg_front_spacedust.png"];
        _planetSunrise = [CCSprite spriteWithFile:@"bg_planetsunrise.png"];
        _galaxy = [CCSprite spriteWithFile:@"bg_galaxy.png"];
        _spacialAnomaly = [CCSprite spriteWithFile:@"bg_spacialanomaly.png"];
        _spacialAnomaly2 = [CCSprite spriteWithFile:@"bg_spacialanomaly2.png"];
        
        
        CGPoint dustSpeed = ccp(0.1, 0.1);
        CGPoint bgSpeed = ccp(0.05, 0.05);
        
        
        [_backgroundNode addChild:_spaceDust1 z:0 parallaxRatio:dustSpeed positionOffset:ccp(0,windowSize.height/2)];
        [_backgroundNode addChild:_spaceDust2 z:0 parallaxRatio:dustSpeed positionOffset:ccp(_spaceDust1.contentSize.width, windowSize.height/2)];
        [_backgroundNode addChild:_galaxy z:-1 parallaxRatio:bgSpeed positionOffset:ccp(0,windowSize.height*0.7)];
        [_backgroundNode addChild:_planetSunrise z:-1 parallaxRatio:bgSpeed positionOffset:ccp(600,windowSize.height *0)];
        [_backgroundNode addChild:_spacialAnomaly z:-1 parallaxRatio:bgSpeed positionOffset:ccp(900,windowSize.height *0.3)];
        [_backgroundNode addChild:_spacialAnomaly2 z:-1 parallaxRatio:bgSpeed positionOffset:ccp(1500,windowSize.height * 0.9)];
		[self scheduleUpdate];
        
        
        
        NSArray *starsArray = [NSArray arrayWithObjects:@"Stars1.plist",@"Stars2.plist", @"Stars3.plist", nil];
        for(NSString *stars in starsArray){
            CCParticleSystemQuad *starsEffect = [CCParticleSystemQuad particleWithFile:stars];
            [self addChild:starsEffect z:1];
            
            self.accelerometerEnabled = YES;
            self.touchEnabled = YES;
        }
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1/60];
        _asteroids = [[CCArray alloc] initWithCapacity:asteroidNumber];
        
        for(int i = 0; i < asteroidNumber; i++){
            CCSprite *asteroid = [CCSprite spriteWithSpriteFrameName:@"asteroid.png"];
            asteroid.visible = NO;
            [_batchNode addChild:asteroid];
            [_asteroids addObject:asteroid];
        }
        
        _shipLasers = [[CCArray alloc] initWithCapacity:shipLasers];
        for (int i = 0; i < shipLasers; i++) {
            CCSprite *shipLaser = [CCSprite spriteWithSpriteFrameName:@"laserbeam_blue.png"];
            shipLaser.visible = NO;
            [_batchNode addChild:shipLaser];
            [_shipLasers addObject:shipLaser];
        }
        _lives = 3;
        double currentTime = CACurrentMediaTime();
        _gameOverTime = currentTime + 30.0;
        
        
	}
	return self;
}

- (void)endScene:(EndReason)endReason {
    
    if (_gameOver) return;
    _gameOver = true;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
    if (endReason == kEndReasonWin) {
        message = @"You win!";
    } else if (endReason == kEndReasonLose) {
        message = @"You lose!";
    }
    
    CCLabelBMFont *label;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        label = [CCLabelBMFont labelWithString:message fntFile:@"Arial-hd.fnt"];
    } else {
        label = [CCLabelBMFont labelWithString:message fntFile:@"Arial.fnt"];
    }
    label.scale = 0.1;
    label.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Arial-hd.fnt"];
    } else {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Arial.fnt"];
    }
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2, winSize.height * 0.4);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    
}

- (void)restartTapped:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:[HelloWorldLayer scene]]];
}

- (float)randomValueBetween:(float)low andValue:(float)high{
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint touchCoordinates = [touch locationInView:touch.view];
    CCLOG(@"X: %f   Y: %f", touchCoordinates.x, touchCoordinates.y);
    
    
    CGSize windowSize = [CCDirector sharedDirector].winSize;
    
    CCSprite *shipLaser = [_shipLasers objectAtIndex:_nextShipLaser];
    _nextShipLaser++;
    if (_nextShipLaser >= _shipLasers.count) {
        _nextShipLaser = 0;
    }
    
    shipLaser.position = ccpAdd(_ship.position, ccp(shipLaser.contentSize.width/2, 0));
    shipLaser.visible = YES;
    
    [shipLaser stopAllActions];
    
    [shipLaser runAction:[CCSequence actions:
                          [CCMoveBy actionWithDuration:0.5 position:ccp(windowSize.width, 0)], [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)] , nil]];
    
    
    
}
#define shipSpeed 50

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    
    CGSize windowSize = [CCDirector sharedDirector].winSize;
    #define kFilteringFactor 0.1
    #define kRestAccelX -0.6
    #define kShipMaxPointsPerSec (windowSize.height*0.5)
    #define kMaxDiffX 0.2
    
    float currentY = _ship.position.y;
    BOOL shouldMove = NO;
    float destY;
    if (acceleration.x >= 0.35) { // up
        destY = currentY + (-1 * acceleration.x * shipSpeed);
        shouldMove = YES;
        CCLOG(@"Tilted: %@", @"UP");
    } else if (acceleration.x < 0.15){ // down
        destY = currentY + (-1 * acceleration.x * shipSpeed);
        shouldMove = YES;
        CCLOG(@"Tilted: %@", @"DOWN");

    } else {
        destY = currentY;
    }
    
    if(shouldMove){
            float realY = MAX(MIN(windowSize.height - (_ship.contentSize.width/2), destY), _ship.contentSize.width/2);
            CCAction *moveShip = [CCMoveTo actionWithDuration:1 position:ccp(_ship.position.x, realY)];
            [moveShip setTag:shipSpeed];
            [_ship runAction:moveShip];
            CCLOG(@"HEIGHT: %f   REALY: %f  XACC: %f", windowSize.height, realY, acceleration.x);
        
    } else {
        [_ship stopActionByTag:shipSpeed];
    }
}

- (void)psp{
    CCLOG(@"X: %f    &     Y: %f", _ship.position.x, _ship.position.y);
}

- (void)update:(ccTime)delta{
    CGSize windowSize = [CCDirector sharedDirector].winSize;
    CGPoint backgroundScrollVelocity = ccp(-1000,0);
    _backgroundNode.position = ccpAdd(_backgroundNode.position, ccpMult(backgroundScrollVelocity, delta));
   
    NSArray *spaceDusts = [NSArray arrayWithObjects:_spaceDust1, _spaceDust2, nil];
    for (CCSprite *spaceDust in spaceDusts) {
        if ([_backgroundNode convertToWorldSpace:spaceDust.position].x < -spaceDust.contentSize.width) {
            [_backgroundNode incrementOffset:ccp(2*spaceDust.contentSize.width,0) forChild:spaceDust];
        }
    }
    
    NSArray *backgrounds = [NSArray arrayWithObjects:_planetSunrise, _galaxy, _spacialAnomaly, _spacialAnomaly2, nil];
    for (CCSprite *background in backgrounds) {
        if ([_backgroundNode convertToWorldSpace:background.position].x < -background.contentSize.width) {
            [_backgroundNode incrementOffset:ccp(2000,0) forChild:background];
        }
    }
    
    double currentTime = CACurrentMediaTime();
    if(currentTime > _nextAsteroidSpawn){
        float randomSeconds = [self randomValueBetween:1.20 andValue:2.0];
        _nextAsteroidSpawn = currentTime + randomSeconds;
        
        float spawnY = [self randomValueBetween:0.0 andValue:windowSize.height];
        float randomDuration = [self randomValueBetween:2.0 andValue:10.0];
        CCSprite *asteroid = [_asteroids objectAtIndex:_nextAsteroid];
        _nextAsteroid++;
        if(_nextAsteroid >= _asteroids.count){
            _nextAsteroid = 0;
        }
        
        [asteroid stopAllActions];
        asteroid.position = ccp(windowSize.width + asteroid.contentSize.width/2, spawnY);
        asteroid.visible = YES;
        
        [asteroid runAction:[CCSequence actions:[CCMoveBy actionWithDuration:randomDuration position:ccp(-windowSize.width-asteroid.contentSize.width, 0)], [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)], nil]];
        
        
    }
    
    for (CCSprite *asteroid in _asteroids) {
        if (!asteroid.visible) continue;
        
        for (CCSprite *shipLaser in _shipLasers) {
            if (!shipLaser.visible) continue;
            
            if (CGRectIntersectsRect(shipLaser.boundingBox, asteroid.boundingBox)) {
                shipLaser.visible = NO;
                asteroid.visible = NO;
                continue;
            }
        }
        if (CGRectIntersectsRect(_ship.boundingBox, asteroid.boundingBox)) {
            asteroid.visible = NO;
            [_ship runAction:[CCBlink actionWithDuration:1.0 blinks:9]];
            _lives--;
        }
    }
    
    if (_lives <= 0) {
        [_ship stopAllActions];
        _ship.visible = FALSE;
        [self endScene:kEndReasonLose];
    } else if (currentTime >= _gameOverTime) {
        [self endScene:kEndReasonWin];
    }

}

- (void)setInvisible:(CCNode *)node{
    node.visible = NO;
}
#pragma mark GameKit delegate

- (void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
