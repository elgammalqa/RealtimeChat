//
// Copyright (c) 2017 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RCAudioPlayer.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCAudioPlayer()

@property (strong, nonatomic) NSMutableDictionary *soundIDs;
@property (strong, nonatomic) NSMutableDictionary *completionBlocks;

- (RCAudioPlayerCompletionBlock)completionBlock:(SystemSoundID)soundID;

- (void)removeCompletionBlock:(SystemSoundID)soundID;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
static void systemServicesSoundCompletion(SystemSoundID soundID, void *data)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RCAudioPlayer *sharedPlayer = [RCAudioPlayer sharedPlayer];
	RCAudioPlayerCompletionBlock completionBlock = [sharedPlayer completionBlock:soundID];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (completionBlock != nil)
	{
		completionBlock();
		[sharedPlayer removeCompletionBlock:soundID];
	}
}

@implementation RCAudioPlayer

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (RCAudioPlayer *)sharedPlayer
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	static dispatch_once_t once;
	static RCAudioPlayer *sharedPlayer;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_once(&once, ^{ sharedPlayer = [[RCAudioPlayer alloc] init]; });
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return sharedPlayer;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)init
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	if (self)
	{
		self.soundIDs = [[NSMutableDictionary alloc] init];
		self.completionBlocks = [[NSMutableDictionary alloc] init];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarningNotification:)
													 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dealloc
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self unloadAllSounds];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

#pragma mark - Public methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)playSound:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([path length] != 0)
		[self playSound:path completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)playSound:(NSString *)path completion:(RCAudioPlayerCompletionBlock)completionBlock
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([path length] != 0)
		[self playSound:path isAlert:NO completionBlock:completionBlock];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)playAlert:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([path length] != 0)
		[self playAlert:path completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)playAlert:(NSString *)path completion:(RCAudioPlayerCompletionBlock)completionBlock
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([path length] != 0)
		[self playSound:path isAlert:YES completionBlock:completionBlock];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)playVibrateSound
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)stopAllSounds
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self unloadAllSounds];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)stopSound:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([path length] != 0)
		[self unloadSound:path];
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)playSound:(NSString *)path isAlert:(BOOL)isAlert completionBlock:(RCAudioPlayerCompletionBlock)completionBlock
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	SystemSoundID soundID;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (self.soundIDs[path] == nil)
	{
		NSURL *url = [NSURL fileURLWithPath:path];
		AudioServicesCreateSystemSoundID((__bridge CFURLRef) url, &soundID);
		self.soundIDs[path] = @(soundID);
	}
	else soundID = [self soundID:path];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (soundID != 0)
	{
		if (completionBlock)
		{
			[self addCompletionBlock:soundID completion:completionBlock];
		}
		
		if (isAlert)
		{
			AudioServicesPlayAlertSound(soundID);
		}
		else AudioServicesPlaySystemSound(soundID);
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (SystemSoundID)soundID:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return (SystemSoundID) [self.soundIDs[path] integerValue];
}

#pragma mark - Completion blocks

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (RCAudioPlayerCompletionBlock)completionBlock:(SystemSoundID)soundID
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [self.completionBlocks objectForKey:@(soundID)];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)addCompletionBlock:(SystemSoundID)soundID completion:(RCAudioPlayerCompletionBlock)completionBlock
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self completionBlock:soundID] == nil)
	{
		[self.completionBlocks setObject:completionBlock forKey:@(soundID)];
		AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, systemServicesSoundCompletion, NULL);
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)removeCompletionBlock:(SystemSoundID)soundID
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self completionBlock:soundID] != nil)
	{
		[self.completionBlocks removeObjectForKey:@(soundID)];
		AudioServicesRemoveSystemSoundCompletion(soundID);
	}
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)unloadAllSounds
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	for (NSString *path in [self.soundIDs allKeys])
	{
		[self unloadSound:path];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)unloadSound:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	SystemSoundID soundID = [self soundID:path];
	if (soundID != 0)
	{
		[self removeCompletionBlock:soundID];
		AudioServicesDisposeSystemSoundID(soundID);
		[self.soundIDs removeObjectForKey:path];
	}
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarningNotification:(NSNotification *)notification
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self unloadAllSounds];
}

@end
