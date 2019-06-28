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

@implementation RCMessages

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (RCMessages *)shared
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	static dispatch_once_t once;
	static RCMessages *rcmessages;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_once(&once, ^{ rcmessages = [[RCMessages alloc] init]; });
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return rcmessages;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)init
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Section
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.sectionHeaderMargin			= 8.0;

	self.sectionHeaderHeight			= 20.0;
	self.sectionHeaderLeft				= 10.0;
	self.sectionHeaderRight				= 10.0;
	self.sectionHeaderColor				= [UIColor lightGrayColor];
	self.sectionHeaderFont				= [UIFont systemFontOfSize:12];

	self.sectionFooterHeight			= 15.0;
	self.sectionFooterLeft				= 10.0;
	self.sectionFooterRight				= 10.0;
	self.sectionFooterColor				= [UIColor lightGrayColor];
	self.sectionFooterFont				= [UIFont systemFontOfSize:12];

	self.sectionFooterMargin			= 8.0;
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Bubble
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.bubbleHeaderHeight				= 15.0;
	self.bubbleHeaderLeft				= 50.0;
	self.bubbleHeaderRight				= 50.0;
	self.bubbleHeaderColor				= [UIColor lightGrayColor];
	self.bubbleHeaderFont				= [UIFont systemFontOfSize:12];

	self.bubbleMarginLeft				= 40.0;
	self.bubbleMarginRight				= 40.0;
	self.bubbleRadius					= 15.0;

	self.bubbleFooterHeight				= 15.0;
	self.bubbleFooterLeft				= 50.0;
	self.bubbleFooterRight				= 50.0;
	self.bubbleFooterColor				= [UIColor lightGrayColor];
	self.bubbleFooterFont				= [UIFont systemFontOfSize:12];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Avatar
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.avatarDiameter					= 30.0;
	self.avatarMarginLeft				= 5.0;
	self.avatarMarginRight				= 5.0;
	
	self.avatarBackColor				= HEXCOLOR(0xD6D6D6FF);
	self.avatarTextColor				= [UIColor whiteColor];
	
	self.avatarFont						= [UIFont systemFontOfSize:12];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Status cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.statusBubbleRadius				= 10.0;

	self.statusBubbleColor				= HEXCOLOR(0x00000030);
	self.statusTextColor				= [UIColor whiteColor];

	self.statusFont						= [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
	
	self.statusInsetLeft				= 10.0;
	self.statusInsetRight				= 10.0;
	self.statusInsetTop					= 5.0;
	self.statusInsetBottom				= 5.0;
	self.statusInset					= UIEdgeInsetsMake(self.statusInsetTop, self.statusInsetLeft, self.statusInsetBottom, self.statusInsetRight);
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Text cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.textBubbleWidthMin				= 45.0;
	self.textBubbleHeightMin			= 35.0;

	self.textBubbleColorOutgoing		= HEXCOLOR(0x007AFFFF);
	self.textBubbleColorIncoming		= HEXCOLOR(0xE6E5EAFF);
	self.textTextColorOutgoing			= [UIColor whiteColor];
	self.textTextColorIncoming			= [UIColor blackColor];

	self.textFont						= [UIFont systemFontOfSize:16];
	self.textInsetLeft					= 10.0;
	self.textInsetRight					= 10.0;
	self.textInsetTop					= 10.0;
	self.textInsetBottom				= 10.0;
	self.textInset						= UIEdgeInsetsMake(self.textInsetTop, self.textInsetLeft, self.textInsetBottom, self.textInsetRight);
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Emoji cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.emojiBubbleWidthMin			= 45.0;
	self.emojiBubbleHeightMin			= 35.0;
	
	self.emojiBubbleColorOutgoing		= HEXCOLOR(0x007AFFFF);
	self.emojiBubbleColorIncoming		= HEXCOLOR(0xE6E5EAFF);

	self.emojiFont						= [UIFont systemFontOfSize:46];

	self.emojiInsetLeft					= 30.0;
	self.emojiInsetRight				= 30.0;
	self.emojiInsetTop					= 5.0;
	self.emojiInsetBottom				= 5.0;
	self.emojiInset						= UIEdgeInsetsMake(self.emojiInsetTop, self.emojiInsetLeft, self.emojiInsetBottom, self.emojiInsetRight);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Picture cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.pictureBubbleWidth				= 200.0;

	self.pictureBubbleColorOutgoing		= [UIColor lightGrayColor];
	self.pictureBubbleColorIncoming		= [UIColor lightGrayColor];

	self.pictureImageManual				= [UIImage imageNamed:@"rcmessages_manual"];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Video cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.videoBubbleWidth				= 200.0;
	self.videoBubbleHeight				= 145.0;

	self.videoBubbleColorOutgoing		= [UIColor lightGrayColor];
	self.videoBubbleColorIncoming		= [UIColor lightGrayColor];
	
	self.videoImagePlay					= [UIImage imageNamed:@"rcmessages_videoplay"];
	self.videoImageManual				= [UIImage imageNamed:@"rcmessages_manual"];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Audio cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.audioBubbleWidht				= 150.0;
	self.audioBubbleHeight				= 40.0;

	self.audioBubbleColorOutgoing		= HEXCOLOR(0x007AFFFF);
	self.audioBubbleColorIncoming		= HEXCOLOR(0xE6E5EAFF);
	self.audioTextColorOutgoing			= [UIColor whiteColor];
	self.audioTextColorIncoming			= [UIColor blackColor];

	self.audioImagePlay					= [UIImage imageNamed:@"rcmessages_audioplay"];
	self.audioImagePause				= [UIImage imageNamed:@"rcmessages_audiopause"];
	self.audioImageManual				= [UIImage imageNamed:@"rcmessages_manual"];

	self.audioFont						= [UIFont systemFontOfSize:16];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Location cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.locationBubbleWidth			= 200.0;
	self.locationBubbleHeight			= 145.0;
	
	self.locationBubbleColorOutgoing	= [UIColor lightGrayColor];
	self.locationBubbleColorIncoming	= [UIColor lightGrayColor];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Input view
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.inputViewBackColor				= [UIColor groupTableViewBackgroundColor];
	self.inputTextBackColor				= [UIColor whiteColor];
	self.inputTextTextColor				= [UIColor blackColor];
	
	self.inputFont						= [UIFont systemFontOfSize:17];
	
	self.inputViewHeightMin				= 44.0;
	self.inputTextHeightMin				= 30.0;
	self.inputTextHeightMax				= 110.0;
	
	self.inputBorderWidth				= 1.0;
	self.inputBorderColor				= [UIColor lightGrayColor].CGColor;
	
	self.inputRadius					= 5.0;
	
	self.inputInsetLeft					= 7.0;
	self.inputInsetRight				= 7.0;
	self.inputInsetTop					= 5.0;
	self.inputInsetBottom				= 5.0;
	self.inputInset						= UIEdgeInsetsMake(self.inputInsetTop, self.inputInsetLeft, self.inputInsetBottom, self.inputInsetRight);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
// Section
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)sectionHeaderMargin				{	return [self shared].sectionHeaderMargin;			}

+ (CGFloat)sectionHeaderHeight				{	return [self shared].sectionHeaderHeight;			}
+ (CGFloat)sectionHeaderLeft				{	return [self shared].sectionHeaderLeft;				}
+ (CGFloat)sectionHeaderRight				{	return [self shared].sectionHeaderRight;			}
+ (UIColor *)sectionHeaderColor				{	return [self shared].sectionHeaderColor;			}
+ (UIFont *)sectionHeaderFont				{	return [self shared].sectionHeaderFont;				}

+ (CGFloat)sectionFooterHeight				{	return [self shared].sectionFooterHeight;			}
+ (CGFloat)sectionFooterLeft				{	return [self shared].sectionFooterLeft;				}
+ (CGFloat)sectionFooterRight				{	return [self shared].sectionFooterRight;			}
+ (UIColor *)sectionFooterColor				{	return [self shared].sectionFooterColor;			}
+ (UIFont *)sectionFooterFont				{	return [self shared].sectionFooterFont;				}

+ (CGFloat)sectionFooterMargin				{	return [self shared].sectionFooterMargin;			}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
// Bubble
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)bubbleHeaderHeight				{	return [self shared].bubbleHeaderHeight;			}
+ (CGFloat)bubbleHeaderLeft					{	return [self shared].bubbleHeaderLeft;				}
+ (CGFloat)bubbleHeaderRight				{	return [self shared].bubbleHeaderRight;				}
+ (UIColor *)bubbleHeaderColor				{	return [self shared].bubbleHeaderColor;				}
+ (UIFont *)bubbleHeaderFont				{	return [self shared].bubbleHeaderFont;				}

+ (CGFloat)bubbleMarginLeft;				{	return [self shared].bubbleMarginLeft;				}
+ (CGFloat)bubbleMarginRight;				{	return [self shared].bubbleMarginRight;				}
+ (CGFloat)bubbleRadius;					{	return [self shared].bubbleRadius;					}

+ (CGFloat)bubbleFooterHeight				{	return [self shared].bubbleFooterHeight;			}
+ (CGFloat)bubbleFooterLeft					{	return [self shared].bubbleFooterLeft;				}
+ (CGFloat)bubbleFooterRight				{	return [self shared].bubbleFooterRight;				}
+ (UIColor *)bubbleFooterColor				{	return [self shared].bubbleFooterColor;				}
+ (UIFont *)bubbleFooterFont				{	return [self shared].bubbleFooterFont;				}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
// Avatar
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)avatarDiameter					{	return [self shared].avatarDiameter;				}
+ (CGFloat)avatarMarginLeft					{	return [self shared].avatarMarginLeft;				}
+ (CGFloat)avatarMarginRight				{	return [self shared].avatarMarginRight;				}

+ (UIColor *)avatarBackColor				{	return [self shared].avatarBackColor;				}
+ (UIColor *)avatarTextColor				{	return [self shared].avatarTextColor;				}

+ (UIFont *)avatarFont						{	return [self shared].avatarFont;					}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
// Status cell
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)statusBubbleRadius;				{	return [self shared].statusBubbleRadius;			}

+ (UIColor *)statusBubbleColor				{	return [self shared].statusBubbleColor;				}
+ (UIColor *)statusTextColor				{	return [self shared].statusTextColor;				}

+ (UIFont *)statusFont						{	return [self shared].statusFont;					}

+ (CGFloat)statusInsetLeft					{	return [self shared].statusInsetLeft;				}
+ (CGFloat)statusInsetRight					{	return [self shared].statusInsetRight;				}
+ (CGFloat)statusInsetTop					{	return [self shared].statusInsetTop;				}
+ (CGFloat)statusInsetBottom				{	return [self shared].statusInsetBottom;				}
+ (UIEdgeInsets)statusInset					{	return [self shared].statusInset;					}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
// Text cell
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)textBubbleWidthMin;				{	return [self shared].textBubbleWidthMin;			}
+ (CGFloat)textBubbleHeightMin;				{	return [self shared].textBubbleHeightMin;			}

+ (UIColor *)textBubbleColorOutgoing		{	return [self shared].textBubbleColorOutgoing;		}
+ (UIColor *)textBubbleColorIncoming		{	return [self shared].textBubbleColorIncoming;		}
+ (UIColor *)textTextColorOutgoing			{	return [self shared].textTextColorOutgoing;			}
+ (UIColor *)textTextColorIncoming			{	return [self shared].textTextColorIncoming;			}

+ (UIFont *)textFont						{	return [self shared].textFont;						}

+ (CGFloat)textInsetLeft					{	return [self shared].textInsetLeft;					}
+ (CGFloat)textInsetRight					{	return [self shared].textInsetRight;				}
+ (CGFloat)textInsetTop						{	return [self shared].textInsetTop;					}
+ (CGFloat)textInsetBottom					{	return [self shared].textInsetBottom;				}
+ (UIEdgeInsets)textInset					{	return [self shared].textInset;						}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
// Emoji cell
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)emojiBubbleWidthMin;				{	return [self shared].emojiBubbleWidthMin;			}
+ (CGFloat)emojiBubbleHeightMin;			{	return [self shared].emojiBubbleHeightMin;			}

+ (UIColor *)emojiBubbleColorOutgoing		{	return [self shared].emojiBubbleColorOutgoing;		}
+ (UIColor *)emojiBubbleColorIncoming		{	return [self shared].emojiBubbleColorIncoming;		}

+ (UIFont *)emojiFont						{	return [self shared].emojiFont;						}

+ (CGFloat)emojiInsetLeft					{	return [self shared].emojiInsetLeft;				}
+ (CGFloat)emojiInsetRight					{	return [self shared].emojiInsetRight;				}
+ (CGFloat)emojiInsetTop					{	return [self shared].emojiInsetTop;					}
+ (CGFloat)emojiInsetBottom					{	return [self shared].emojiInsetBottom;				}
+ (UIEdgeInsets)emojiInset					{	return [self shared].emojiInset;					}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
// Picture cell
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)pictureBubbleWidth;				{	return [self shared].pictureBubbleWidth;			}

+ (UIColor *)pictureBubbleColorOutgoing		{	return [self shared].pictureBubbleColorOutgoing;	}
+ (UIColor *)pictureBubbleColorIncoming		{	return [self shared].pictureBubbleColorIncoming;	}

+ (UIImage *)pictureImageManual				{	return [self shared].pictureImageManual;			}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
// Video cell
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)videoBubbleWidth;				{	return [self shared].videoBubbleWidth;				}
+ (CGFloat)videoBubbleHeight;				{	return [self shared].videoBubbleHeight;				}

+ (UIColor *)videoBubbleColorOutgoing		{	return [self shared].videoBubbleColorOutgoing;		}
+ (UIColor *)videoBubbleColorIncoming		{	return [self shared].videoBubbleColorIncoming;		}

+ (UIImage *)videoImagePlay					{	return [self shared].videoImagePlay;				}
+ (UIImage *)videoImageManual				{	return [self shared].videoImageManual;				}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
// Audio cell
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)audioBubbleWidht;				{	return [self shared].audioBubbleWidht;				}
+ (CGFloat)audioBubbleHeight;				{	return [self shared].audioBubbleHeight;				}

+ (UIColor *)audioBubbleColorOutgoing		{	return [self shared].audioBubbleColorOutgoing;		}
+ (UIColor *)audioBubbleColorIncoming		{	return [self shared].audioBubbleColorIncoming;		}
+ (UIColor *)audioTextColorOutgoing			{	return [self shared].audioTextColorOutgoing;		}
+ (UIColor *)audioTextColorIncoming			{	return [self shared].audioTextColorIncoming;		}

+ (UIImage *)audioImagePlay					{	return [self shared].audioImagePlay;				}
+ (UIImage *)audioImagePause				{	return [self shared].audioImagePause;				}
+ (UIImage *)audioImageManual				{	return [self shared].audioImageManual;				}

+ (UIFont *)audioFont						{	return [self shared].audioFont;						}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
// Location cell
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)locationBubbleWidth;				{	return [self shared].locationBubbleWidth;			}
+ (CGFloat)locationBubbleHeight;			{	return [self shared].locationBubbleHeight;			}

+ (UIColor *)locationBubbleColorOutgoing	{	return [self shared].locationBubbleColorOutgoing;	}
+ (UIColor *)locationBubbleColorIncoming	{	return [self shared].locationBubbleColorIncoming;	}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
// Input view
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (UIColor *)inputViewBackColor				{	return [self shared].inputViewBackColor;			}
+ (UIColor *)inputTextBackColor				{	return [self shared].inputTextBackColor;			}
+ (UIColor *)inputTextTextColor				{	return [self shared].inputTextTextColor;			}

+ (UIFont *)inputFont						{	return [self shared].inputFont;						}

+ (CGFloat)inputViewHeightMin				{	return [self shared].inputViewHeightMin;			}
+ (CGFloat)inputTextHeightMin				{	return [self shared].inputTextHeightMin;			}
+ (CGFloat)inputTextHeightMax				{	return [self shared].inputTextHeightMax;			}

+ (CGFloat)inputBorderWidth					{	return [self shared].inputBorderWidth;				}
+ (CGColorRef)inputBorderColor				{	return [self shared].inputBorderColor;				}

+ (CGFloat)inputRadius						{	return [self shared].inputRadius;					}

+ (CGFloat)inputInsetLeft					{	return [self shared].inputInsetLeft;				}
+ (CGFloat)inputInsetRight					{	return [self shared].inputInsetRight;				}
+ (CGFloat)inputInsetTop					{	return [self shared].inputInsetTop;					}
+ (CGFloat)inputInsetBottom					{	return [self shared].inputInsetBottom;				}
+ (UIEdgeInsets)inputInset					{	return [self shared].inputInset;					}
//-------------------------------------------------------------------------------------------------------------------------------------------------

@end
