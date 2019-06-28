//
// Copyright (c) 2018 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RCMessages.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCMessage : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

#pragma mark - Properties

@property (assign, nonatomic) NSInteger type;

@property (assign, nonatomic) BOOL incoming;
@property (assign, nonatomic) BOOL outgoing;

@property (strong, nonatomic) NSString *text;

@property (strong, nonatomic) UIImage *picture_image;
@property (assign, nonatomic) NSInteger picture_width;
@property (assign, nonatomic) NSInteger picture_height;

@property (strong, nonatomic) NSString *video_path;
@property (strong, nonatomic) UIImage *video_thumbnail;
@property (assign, nonatomic) NSInteger video_duration;

@property (strong, nonatomic) NSString *audio_path;
@property (assign, nonatomic) NSInteger audio_duration;
@property (assign, nonatomic) NSInteger audio_status;

@property (assign, nonatomic) CLLocationDegrees latitude;
@property (assign, nonatomic) CLLocationDegrees longitude;
@property (strong, nonatomic) UIImage *location_thumbnail;

@property (assign, nonatomic) NSInteger status;

#pragma mark - Initialization methods

- (id)initWithStatus:(NSString *)text;

- (id)initWithText:(NSString *)text incoming:(BOOL)incoming;

- (id)initWithEmoji:(NSString *)text incoming:(BOOL)incoming;

- (id)initWithPicture:(UIImage *)image width:(NSInteger)width height:(NSInteger)height incoming:(BOOL)incoming;

- (id)initWithVideo:(NSString *)path durarion:(NSInteger)duration incoming:(BOOL)incoming;

- (id)initWithAudio:(NSString *)path durarion:(NSInteger)duration incoming:(BOOL)incoming;

- (id)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude incoming:(BOOL)incoming
			completion:(void (^)(void))completion;

@end
