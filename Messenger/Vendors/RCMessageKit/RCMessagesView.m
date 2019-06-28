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

#import "RCMessagesView.h"

#import "RCSectionHeaderCell.h"
#import "RCBubbleHeaderCell.h"
#import "RCBubbleFooterCell.h"
#import "RCSectionFooterCell.h"

#import "RCStatusCell.h"
#import "RCTextMessageCell.h"
#import "RCEmojiMessageCell.h"
#import "RCPictureMessageCell.h"
#import "RCVideoMessageCell.h"
#import "RCAudioMessageCell.h"
#import "RCLocationMessageCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCMessagesView()
{
	BOOL initialized;
	CGPoint centerView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RCMessagesView

@synthesize viewTitle, labelTitle1, labelTitle2, buttonTitle;
@synthesize viewLoadEarlier;
@synthesize viewTypingIndicator;
@synthesize viewInput, buttonInputAttach, textInput, buttonInputSend;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)init
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [self initWithNibName:@"RCMessagesView" bundle:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.titleView = viewTitle;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView registerClass:[RCSectionHeaderCell class] forCellReuseIdentifier:@"RCSectionHeaderCell"];
	[self.tableView registerClass:[RCBubbleHeaderCell class] forCellReuseIdentifier:@"RCBubbleHeaderCell"];
	[self.tableView registerClass:[RCBubbleFooterCell class] forCellReuseIdentifier:@"RCBubbleFooterCell"];
	[self.tableView registerClass:[RCSectionFooterCell class] forCellReuseIdentifier:@"RCSectionFooterCell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView registerClass:[RCTextMessageCell class] forCellReuseIdentifier:@"RCTextMessageCell"];
	[self.tableView registerClass:[RCEmojiMessageCell class] forCellReuseIdentifier:@"RCEmojiMessageCell"];
	[self.tableView registerClass:[RCPictureMessageCell class] forCellReuseIdentifier:@"RCPictureMessageCell"];
	[self.tableView registerClass:[RCVideoMessageCell class] forCellReuseIdentifier:@"RCVideoMessageCell"];
	[self.tableView registerClass:[RCAudioMessageCell class] forCellReuseIdentifier:@"RCAudioMessageCell"];
	[self.tableView registerClass:[RCLocationMessageCell class] forCellReuseIdentifier:@"RCLocationMessageCell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView registerClass:[RCStatusCell class] forCellReuseIdentifier:@"RCStatusCell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewLoadEarlier;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardDidHideNotification object:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self inputPanelInit];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLayoutSubviews
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLayoutSubviews];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	centerView = self.view.center;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self inputPanelUpdate];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillAppear:animated];
	[self dismissKeyboard];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (initialized == NO)
	{
		initialized = YES;
		[self scrollToBottom:YES];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	centerView = self.view.center;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	[self dismissKeyboard];
}

#pragma mark - Load earlier methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadEarlierShow:(BOOL)show
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	viewLoadEarlier.hidden = !show;
	CGRect frame = viewLoadEarlier.frame;
	frame.size.height = show ? 50 : 0;
	viewLoadEarlier.frame = frame;
	[self.tableView reloadData];
}

#pragma mark - Message methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (RCMessage *)rcmessage:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

#pragma mark - Avatar methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)avatarInitials:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIImage *)avatarImage:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

#pragma mark - Header, Footer methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)textSectionHeader:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)textBubbleHeader:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)textBubbleFooter:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)textSectionFooter:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

#pragma mark - Menu controller methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSArray *)menuItems:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)canBecomeFirstResponder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

#pragma mark - Typing indicator methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorShow:(BOOL)show animated:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (show)
	{
		self.tableView.tableFooterView = viewTypingIndicator;
		[self scrollToBottom:animated];
	}
	else
	{
		[UIView animateWithDuration:(animated ? 0.25 : 0) animations:^{
			self.tableView.tableFooterView = nil;
		}];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorUpdate
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - Keyboard methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)keyboardShow:(NSNotification *)notification
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *info = [notification userInfo];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGRect keyboard = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat heightKeyboard = keyboard.size.height;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		self.view.center = CGPointMake(self->centerView.x, self->centerView.y - heightKeyboard + self.view.safeAreaInsets.bottom);
	} completion:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[UIMenuController sharedMenuController] setMenuItems:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)keyboardHide:(NSNotification *)notification
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *info = [notification userInfo];
	NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		self.view.center = self->centerView;
	} completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

#pragma mark - Input panel methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)inputPanelInit
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	viewInput.backgroundColor = [RCMessages inputViewBackColor];
	textInput.backgroundColor = [RCMessages inputTextBackColor];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	textInput.font = [RCMessages inputFont];
	textInput.textColor = [RCMessages inputTextTextColor];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	textInput.textContainer.lineFragmentPadding = 0;
	textInput.textContainerInset = [RCMessages inputInset];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	textInput.layer.borderColor = [RCMessages inputBorderColor];
	textInput.layer.borderWidth = [RCMessages inputBorderWidth];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	textInput.layer.cornerRadius = [RCMessages inputRadius];
	textInput.clipsToBounds = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)inputPanelUpdate
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat heightView = self.view.frame.size.height;
	CGFloat widthView = self.view.frame.size.width;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat leftSafe = self.view.safeAreaInsets.left;
	CGFloat rightSafe = self.view.safeAreaInsets.right;
	CGFloat bottomSafe = self.view.safeAreaInsets.bottom;
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthText = textInput.frame.size.width, heightText;
	CGSize sizeText = [textInput sizeThatFits:CGSizeMake(widthText, MAXFLOAT)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	heightText = fmaxf([RCMessages inputTextHeightMin], sizeText.height);
	heightText = fminf([RCMessages inputTextHeightMax], heightText);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat heightInput = heightText + ([RCMessages inputViewHeightMin] - [RCMessages inputTextHeightMin]);
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.frame = CGRectMake(leftSafe, 0, widthView - leftSafe - rightSafe, heightView - bottomSafe - heightInput);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGRect frameViewInput = viewInput.frame;
	frameViewInput.origin.y = heightView - bottomSafe - heightInput;
	frameViewInput.size.height = heightInput;
	viewInput.frame = frameViewInput;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[viewInput layoutIfNeeded];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGRect frameAttach = buttonInputAttach.frame;
	frameAttach.origin.y = heightInput - frameAttach.size.height;
	buttonInputAttach.frame = frameAttach;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGRect frameTextInput = textInput.frame;
	frameTextInput.size.height = heightText;
	textInput.frame = frameTextInput;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGRect frameSend = buttonInputSend.frame;
	frameSend.origin.y = heightInput - frameSend.size.height;
	buttonInputSend.frame = frameSend;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	buttonInputSend.enabled = ([textInput.text length] != 0);
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGPoint offset = CGPointMake(0, sizeText.height - heightText);
	[textInput setContentOffset:offset animated:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self scrollToBottom:NO];
}

#pragma mark - User actions (title)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionTitle:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self actionTitle];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTitle
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - User actions (load earlier)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLoadEarlier:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self actionLoadEarlier];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLoadEarlier
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - User actions (bubble tap)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTapBubble:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - User actions (avatar tap)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTapAvatar:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - User actions (input panel)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionInputAttach:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self actionAttachMessage];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionInputSend:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([textInput.text length] != 0)
	{
		[self actionSendMessage:textInput.text];
		[self dismissKeyboard];
		textInput.text = nil;
		[self inputPanelUpdate];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAttachMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSendMessage:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - UIScrollViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissKeyboard];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 5;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [RCMessages sectionHeaderMargin];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [RCMessages sectionFooterMargin];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	view.tintColor = [UIColor clearColor];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	view.tintColor = [UIColor clearColor];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.row == 0) // Section header
	{
		return [RCSectionHeaderCell height:indexPath messagesView:self];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.row == 1) // Bubble header
	{
		return [RCBubbleHeaderCell height:indexPath messagesView:self];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.row == 2) // Message body
	{
		RCMessage *rcmessage = [self rcmessage:indexPath];
		if (rcmessage.type == RC_TYPE_STATUS)	return [RCStatusCell height:indexPath messagesView:self];
		if (rcmessage.type == RC_TYPE_TEXT)		return [RCTextMessageCell height:indexPath messagesView:self];
		if (rcmessage.type == RC_TYPE_EMOJI)	return [RCEmojiMessageCell height:indexPath messagesView:self];
		if (rcmessage.type == RC_TYPE_PICTURE)	return [RCPictureMessageCell height:indexPath messagesView:self];
		if (rcmessage.type == RC_TYPE_VIDEO)	return [RCVideoMessageCell height:indexPath messagesView:self];
		if (rcmessage.type == RC_TYPE_AUDIO)	return [RCAudioMessageCell height:indexPath messagesView:self];
		if (rcmessage.type == RC_TYPE_LOCATION)	return [RCLocationMessageCell height:indexPath messagesView:self];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.row == 3) // Bubble footer
	{
		return [RCBubbleFooterCell height:indexPath messagesView:self];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.row == 4) // Section footer
	{
		return [RCSectionFooterCell height:indexPath messagesView:self];
	}
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.row == 0)	// Section header
	{
		RCSectionHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCSectionHeaderCell" forIndexPath:indexPath];
		[cell bindData:indexPath messagesView:self];
		return cell;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.row == 1) // Bubble header
	{
		RCBubbleHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCBubbleHeaderCell" forIndexPath:indexPath];
		[cell bindData:indexPath messagesView:self];
		return cell;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.row == 2) // Message body
	{
		RCMessage *rcmessage = [self rcmessage:indexPath];
		if (rcmessage.type == RC_TYPE_STATUS)
		{
			RCStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCStatusCell" forIndexPath:indexPath];
			[cell bindData:indexPath messagesView:self];
			return cell;
		}
		if (rcmessage.type == RC_TYPE_TEXT)
		{
			RCTextMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCTextMessageCell" forIndexPath:indexPath];
			[cell bindData:indexPath messagesView:self];
			return cell;
		}
		if (rcmessage.type == RC_TYPE_EMOJI)
		{
			RCEmojiMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCEmojiMessageCell" forIndexPath:indexPath];
			[cell bindData:indexPath messagesView:self];
			return cell;
		}
		if (rcmessage.type == RC_TYPE_PICTURE)
		{
			RCPictureMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCPictureMessageCell" forIndexPath:indexPath];
			[cell bindData:indexPath messagesView:self];
			return cell;
		}
		if (rcmessage.type == RC_TYPE_VIDEO)
		{
			RCVideoMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCVideoMessageCell" forIndexPath:indexPath];
			[cell bindData:indexPath messagesView:self];
			return cell;
		}
		if (rcmessage.type == RC_TYPE_AUDIO)
		{
			RCAudioMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCAudioMessageCell" forIndexPath:indexPath];
			[cell bindData:indexPath messagesView:self];
			return cell;
		}
		if (rcmessage.type == RC_TYPE_LOCATION)
		{
			RCLocationMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCLocationMessageCell" forIndexPath:indexPath];
			[cell bindData:indexPath messagesView:self];
			return cell;
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.row == 3) // Bubble footer
	{
		RCBubbleFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCBubbleFooterCell" forIndexPath:indexPath];
		[cell bindData:indexPath messagesView:self];
		return cell;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.row == 4) // Section footer
	{
		RCSectionFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCSectionFooterCell" forIndexPath:indexPath];
		[cell bindData:indexPath messagesView:self];
		return cell;
	}
	return nil;
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)scrollToBottom:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self.tableView numberOfSections] > 0)
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:([self.tableView numberOfSections] - 1)];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
	}
}

#pragma mark - UITextViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)textViewDidChange:(UITextView *)textView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self inputPanelUpdate];
	[self typingIndicatorUpdate];
}

@end
