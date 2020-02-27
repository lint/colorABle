
//made for u/completebunk

#import "UIColor+CSColorPicker.h"

@interface ABToolbar : UIToolbar
@end

@interface TransparentToolbar: ABToolbar
@end

@interface UIImage (AverageColor)
-(UIColor *) averageColor;
@end

//from http://www.bobbygeorgescu.com/2011/08/finding-average-color-of-uiimage/
@implementation UIImage (AverageColor) 
-(UIColor *) averageColor{
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);  
	
	return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0 green:((CGFloat)rgba[1])/255.0 blue:((CGFloat)rgba[2])/255.0 alpha:((CGFloat)rgba[3])/255.0];
}
@end


static BOOL isEnabled;
static UIColor *upvoteColor;
static UIColor *downvoteColor;
static UIColor *opHighlightColor;
static UIColor *tintColor;
static UIColor *inboxColor;

static BOOL colorsAreEqual(UIColor* color1, UIColor *color2){
	
	const CGFloat *color1Parts = CGColorGetComponents([color1 CGColor]);
	CGFloat r1 = color1Parts[0];
	CGFloat g1 = color1Parts[1];
	CGFloat b1 = color1Parts[2];
	
	const CGFloat *color2Parts = CGColorGetComponents([color2 CGColor]);
	CGFloat r2 = color2Parts[0];
	CGFloat g2 = color2Parts[1];
	CGFloat b2 = color2Parts[2];
	
	if (fabs(r1 - r2) <= .001 && fabs(g1 - g2) <= .001 && fabs(b1 - b2) <= .001){
		return YES;
	} else {
		return NO;
	}
}


%hook UIColor

+(id) colorForUpvote{
	return upvoteColor;
}

+(id) colorForDownvote{
	return downvoteColor;
}

+(id) colorForOpHighlight{
	return opHighlightColor;
}

+(id) colorForTint{
	return tintColor;
}

+(id) colorForHighlightedOptions{
	return tintColor;
}

+(id) colorForInboxAlert{
	return inboxColor;
}

//username highlight color when getting context
+(id) colorWithCGColor:(CGColorRef) arg1{
	
	%log;
	id orig = %orig;
	
	UIColor *compColor = [UIColor colorWithRed:183.0/255 green:106.0/255 blue:255.0/255 alpha:1.0];
	
	if (colorsAreEqual(orig, compColor)){
		orig = opHighlightColor;
	}
	
	return orig;
}

%end


//New mail alert
%hook ABToolbar

-(void) handleTintSwitch{
	%orig;
	
	NSArray *items = [self items];
	
	for (UIBarButtonItem *item in items){
		UIView *view = [item customView];
		
		if ([view isKindOfClass:[UIButton class]]){
			UIButton *button = (UIButton *)view;
			
			UIImage *image = button.currentImage;
			UIColor *avgColor = [image averageColor];
			
			if (colorsAreEqual(avgColor, [UIColor colorWithRed:0.109804 green:0.0470588 blue:0.0392157 alpha:0.117647])){	
				
				UIImage *newImage = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/colorABlePrefs.bundle/newmail.png"];
				newImage = [UIImage imageWithCGImage:[newImage CGImage] scale:2.0 orientation:UIImageOrientationUp];
				newImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
				
				[button setImage:newImage forState:UIControlStateNormal];
				[button setTintColor:inboxColor];
				
				break;
			}
		}
	}
}

%end

//Upvote arrow color in top nav bar
%hook TransparentToolbar

-(void) layoutSubviews{
	%orig;
	
	NSArray *items = [self items];
	
	for (UIBarButtonItem *item in items){
		UIView *view = [item customView];
		
		if ([view isKindOfClass:[UIButton class]]){
			
			UIButton *button = (UIButton *)view;
			UIImage *btnImage = [button currentImage];
			UIColor *avgColor = [btnImage averageColor];
			
			if (colorsAreEqual(avgColor, [UIColor colorWithRed:0.0352941 green:0.0196078 blue:0.00784314 alpha:0.0])){
				[button setImage:[button.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal] ;
				[button setTintColor:upvoteColor];
			}
		}
	}
}

%end


%hook Comment

-(id) styledBody{
	
	id orig = %orig;
	
	if (orig != nil){
	
		NSMutableAttributedString *styledText;	
		CGFloat compR1, compG1, compB1, compR2, compG2, compB2;
		
		compR1 = 0.678431;
		compG1 = 0.286275;
		compB1 = 0.882353;
		
		compR2 = 0.854902;
		compG2 = 0.290196;
		compB2 = 0.729412;
		
		if (![orig isKindOfClass:[NSMutableAttributedString class]] && [orig isKindOfClass:[NSAttributedString class]]){
			styledText = [orig mutableCopy];
		} else {
			styledText = (NSMutableAttributedString *) orig;
		}

		[styledText enumerateAttribute:@"CTForegroundColor" inRange:NSMakeRange(0, [styledText length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop){
			
			CGColor *color = (__bridge CGColor *) value;
			
			if (color != nil){

				const CGFloat *components = CGColorGetComponents(color);
				CGFloat origRed = components[0];
				CGFloat origGreen = components[1];
				CGFloat origBlue = components[2];
				
				if (fabs(origRed - compR1) <= .001 && fabs(origGreen - compG1) <= .001 && fabs(origBlue - compB1) <= .001){ //color of header 4
					[styledText addAttribute:@"CTForegroundColor" value:tintColor range:range];
				} else if (fabs(origRed - compR2) <= .001 && fabs(origGreen - compG2) <= .001 && fabs(origBlue - compB2) <= .001){ //color of show table
					[styledText addAttribute:@"CTForegroundColor" value:tintColor range:range];
				} 
			}
		}];
		
		return styledText;
	}
	else{
		
		return orig;
	}
}

%end


static void loadPrefs(){
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/com.lint.colorable.prefs.plist"];
	
	if (prefs){
		
		if ([prefs objectForKey:@"isEnabled"] != nil){
			isEnabled = [[prefs objectForKey:@"isEnabled"] boolValue];
		} else {
			isEnabled = YES;
		}
		
		if ([prefs objectForKey:@"upvoteColor"]){
			upvoteColor = [UIColor cscp_colorFromHexString:[prefs objectForKey:@"upvoteColor"]];
		} else {
			upvoteColor = [UIColor cscp_colorFromHexString:@"FF4500"];
		}
		
		if ([prefs objectForKey:@"downvoteColor"]){
			downvoteColor = [UIColor cscp_colorFromHexString:[prefs objectForKey:@"downvoteColor"]];
		} else {
			downvoteColor = [UIColor cscp_colorFromHexString:@"659BFD"];
		}
		
		if ([prefs objectForKey:@"opHighlightColor"]){
			opHighlightColor = [UIColor cscp_colorFromHexString:[prefs objectForKey:@"opHighlightColor"]];
		} else {
			opHighlightColor = [UIColor cscp_colorFromHexString:@"D40CBF"];
		}
		
		if ([prefs objectForKey:@"tintColor"]){
			tintColor = [UIColor cscp_colorFromHexString:[prefs objectForKey:@"tintColor"]];
		} else {
			tintColor = [UIColor cscp_colorFromHexString:@"0D7EAC"];
		}
		
		if ([prefs objectForKey:@"newInboxColor"]){
			inboxColor = [UIColor cscp_colorFromHexString:[prefs objectForKey:@"newInboxColor"]];
		} else {
			inboxColor = [UIColor cscp_colorFromHexString:@"7D26CD"];
		}
		
	} else {
		isEnabled = NO;
	}	
}


static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  loadPrefs();
}


%ctor {
	loadPrefs();
	
	if (isEnabled){
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, prefsChanged, CFSTR("com.lint.colorable.prefs.changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		%init;
	}
}
