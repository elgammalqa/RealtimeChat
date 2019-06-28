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

#ifndef app_utilities_h
#define app_utilities_h

#import <AVKit/AVKit.h>
#import <Contacts/Contacts.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreSpotlight/CoreSpotlight.h>
#import <CommonCrypto/CommonCrypto.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>

#pragma mark -

#import <ApiAI/ApiAI.h>
#import <Firebase/Firebase.h>
#import <OneSignal/OneSignal.h>
#import <Realm/Realm.h>
#import <Sinch/Sinch.h>
#import "SinchService.h"

#pragma mark -

#import "MBProgressHUD.h"
#import "MGSwipeTableCell.h"
#import "NYTPhotoViewer.h"
#import "ProgressHUD.h"
#import "RCAudioPlayer.h"
#import "RCMessagesView.h"
#import "Reachability.h"
#import "RNDecryptor.h"
#import "RNEncryptor.h"
#import "SoundManager.h"

#pragma mark -

#import "AppConstant.h"

#pragma mark - backend1

#import "FObject.h"
#import "FUser.h"
#import "FUser+Util.h"
#import "NSError+Util.h"

#pragma mark - backend2

#import "Blockeds.h"
#import "Blockers.h"
#import "CallHistories.h"
#import "Friends.h"
#import "Groups.h"
#import "Messages.h"
#import "Statuses.h"
#import "Users.h"
#import "UserStatuses.h"

#pragma mark - backend3

#import "Account.h"
#import "Blocked.h"
#import "Blocker.h"
#import "CallHistory.h"
#import "Chat.h"
#import "Friend.h"
#import "Group.h"
#import "LinkedId.h"
#import "Message.h"
#import "Status.h"
#import "UserStatus.h"

#pragma mark - backend4

#import "push.h"
#import "user.h"

#pragma mark - general1

#import "NotificationCenter.h"
#import "NSDate+Util.h"
#import "NSDictionary+Util.h"
#import "UserDefaults.h"

#pragma mark - general2

#import "Connection.h"
#import "Location.h"

#pragma mark - general3

#import "Audio.h"
#import "Checksum.h"
#import "Cryptor.h"	
#import "Dir.h"
#import "Emoji.h"
#import "File.h"
#import "Image.h"
#import "Password.h"
#import "Shortcut.h"
#import "Video.h"

#pragma mark - general4

#import "camera.h"
#import "converter.h"

#pragma mark - manager

#import "CacheManager.h"
#import "DownloadManager.h"
#import "MediaLoader.h"
#import "RealmManager.h"
#import "RelayManager.h"
#import "UploadManager.h"

#pragma mark - messages

#import "MessageQueue.h"
#import "MessageRelay.h"

#pragma mark - other

#import "NYTPhotoItem.h"

#pragma mark - realm

#import "DBBlocked.h"
#import "DBBlocker.h"
#import "DBCallHistory.h"
#import "DBChat.h"
#import "DBFriend.h"
#import "DBGroup.h"
#import "DBMessage.h"
#import "DBStatus.h"
#import "DBUser.h"
#import "DBUserStatus.h"

#endif
