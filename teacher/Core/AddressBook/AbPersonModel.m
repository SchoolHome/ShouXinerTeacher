//
//  AddressBookPersonModel.m
//  
//
//  Created by yong weiy on 12-3-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AbPersonModel.h"
#import "ABPersonMultiValueModel.h"

@implementation UIImage (Extras)  

#pragma mark -  
#pragma mark Scale and crop image  
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize  
{  
	UIImage *sourceImage = self;  
	UIImage *newImage = nil;          
	CGSize imageSize = sourceImage.size;  
	CGFloat width = imageSize.width;  
	CGFloat height = imageSize.height;  
	CGFloat targetWidth = targetSize.width;  
	CGFloat targetHeight = targetSize.height;  
	CGFloat scaleFactor = 0.0;  
	CGFloat scaledWidth = targetWidth;  
	CGFloat scaledHeight = targetHeight;  
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);  
	if (CGSizeEqualToSize(imageSize, targetSize) == NO)   
	{  
        CGFloat widthFactor = targetWidth / width;  
        CGFloat heightFactor = targetHeight / height;  
        if (widthFactor > heightFactor)   
			scaleFactor = widthFactor; // scale to fit height  
        else  
			scaleFactor = heightFactor; // scale to fit width  
        scaledWidth  = width * scaleFactor;  
        scaledHeight = height * scaleFactor;  
        // center the image  
        if (widthFactor > heightFactor)  
		{  
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;   
		}  
        else   
			if (widthFactor < heightFactor)  
			{  
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;  
			}  
	}         
	UIGraphicsBeginImageContext(targetSize); // this will crop  
	CGRect thumbnailRect = CGRectZero;  
	thumbnailRect.origin = thumbnailPoint;  
	thumbnailRect.size.width  = scaledWidth;  
	thumbnailRect.size.height = scaledHeight;  
	[sourceImage drawInRect:thumbnailRect];  
	newImage = UIGraphicsGetImageFromCurrentImageContext();  
	if(newImage == nil)   
        CPLogInfo(@"could not scale image");  
	//pop the context to get back to the default  
	UIGraphicsEndImageContext();  
	return newImage;  
} 

@end


@implementation AbPersonModel

@synthesize recordID = recordID_;
@synthesize fullName = fullName_;
@synthesize firstName = firstName_;
@synthesize middleName = middleName_;
@synthesize lastName = lastName_;
@synthesize prefix = prefix_;
@synthesize suffix = suffix_;
@synthesize nickname = nickname_;
@synthesize firstNamePhonetic = firstNamePhonetic_;
@synthesize lastNamePhonetic = lastNamePhonetic_;
@synthesize middleNamePhonetic = middleNamePhonetic_;
@synthesize company = company_;
@synthesize job = job_;
@synthesize department = department_;
@synthesize note = note_;
@synthesize birthday = birthday_;
@synthesize createDate = createDate_;
@synthesize updateDate = updateDate_;
@synthesize phones = phones_;
@synthesize emails = emails_;
@synthesize urls = urls_;
@synthesize addrs = addrs_;
@synthesize IMs = IMs_;
@synthesize headerPhotoData = headerPhotoData_;
@synthesize abPersonState = abPersonState_;

-(NSString*)getStringPropertyFromRecordRef:(ABRecordRef)recordref propertyId:(ABPropertyID)abPropertyID
{
	if (nil == recordref) 
    {
		return Nil;
	}
	return (__bridge_transfer NSString *)ABRecordCopyValue(recordref,abPropertyID);
}
-(NSData*)getPhotoImgFromRecordRef:(ABRecordRef)recordref
{
	if (nil == recordref) 
    {
		return Nil;
	}
	if (!ABPersonHasImageData(recordref))
	{
		return Nil;
	}
	return (__bridge_transfer NSData *)ABPersonCopyImageData(recordref);
}
-(NSData*)getPhotoImgThumbnailFromRecordRef:(ABRecordRef)recordref
{
	if (nil == recordref) 
    {
		return Nil;
	}
	return (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(recordref,kABPersonImageFormatThumbnail);
}

-(NSDate *)getDateTimePropertyFromRecordRef:(ABRecordRef)recordref propertyId:(ABPropertyID)abPropertyID
{
	if (nil == recordref) 
    {
		return nil;
	}
	//return (__bridge NSDate *)ABRecordCopyValue(recordref,abPropertyID);
    return CFBridgingRelease(ABRecordCopyValue(recordref,abPropertyID));
}
-(NSMutableArray*) getMultiStringPropertyFromRecordRef:(ABRecordRef)recordref propertyId:(ABPropertyID)abPropertyID
{
	if (nil == recordref) 
    {
		return nil;
	}
	ABMultiValueRef phones = (ABMultiValueRef) ABRecordCopyValue(recordref, abPropertyID);
	if (nil == phones) 
    {
		return nil;
	}
	int nCount = ABMultiValueGetCount(phones);
	if (nCount < 1) 
    {
		CFRelease(phones);
		return nil;
	}
	NSMutableArray *mularray = [[NSMutableArray alloc] init];
	for(int i = 0 ;i < nCount;i++)
	{
		NSString *Lable = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(phones, i);
		NSString *Value = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
        //		if ([Lable  isEqual:kABHomeLabel] || [Lable isEqual:kABWorkLabel] || [Lable isEqual:kABOtherLabel])
        //		{
        //			[MutableDict setValue:Value forKey:Lable];
        //		}
		ABPersonMultiValueModel * item = [[ABPersonMultiValueModel alloc] initWithLabelAndString:Lable string:Value];
		[mularray addObject:item];
	}
	CFRelease(phones);
	return mularray;
}
-(NSMutableArray*) getMultiDictionatyPropertyFromRecordRef:(ABRecordRef)recordref propertyId:(ABPropertyID)abPropertyID
{
	if (nil == recordref) 
    {
		return nil;
	}
	ABMultiValueRef address = (ABMultiValueRef) ABRecordCopyValue(recordref, abPropertyID);
	if (nil == address) 
    {
		return nil;
	}
	int nCount = ABMultiValueGetCount(address);
	if (nCount < 1) 
    {
		CFRelease(address);
		return nil;
	}
	NSMutableArray* mularray = [NSMutableArray arrayWithCapacity:5];
	for(int i = 0 ;i < nCount;i++)
	{
		NSMutableDictionary *multiValueDic = [[NSMutableDictionary alloc] init];
		
		NSString *Lable = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(address, i);
		NSDictionary *Value = (__bridge_transfer NSDictionary *)ABMultiValueCopyValueAtIndex(address, i);  
		if (kABPersonAddressProperty == abPropertyID) 
        {
		    NSString* country = [Value valueForKey:(NSString *)kABPersonAddressCountryKey];
		    [multiValueDic setValue:country forKey:(NSString *)kABPersonAddressCountryKey];
            
		    NSString* city = [Value valueForKey:(NSString *)kABPersonAddressCityKey];
		    [multiValueDic setValue:city forKey:(NSString *)kABPersonAddressCityKey];
            
		    NSString* state = [Value valueForKey:(NSString *)kABPersonAddressStateKey];
		    [multiValueDic setValue:state forKey:(NSString *)kABPersonAddressStateKey];
            
		    NSString* street = [Value valueForKey:(NSString *)kABPersonAddressStreetKey];
		    [multiValueDic setValue:street forKey:(NSString *)kABPersonAddressStreetKey];
            
		    NSString* zip = [Value valueForKey:(NSString *)kABPersonAddressZIPKey];
		    [multiValueDic setValue:zip forKey:(NSString *)kABPersonAddressZIPKey];
            
		    NSString* coutntrycode = [Value valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
		    [multiValueDic setValue:coutntrycode forKey:(NSString *)kABPersonAddressCountryCodeKey];
            
	     	ABPersonMultiValueModel * item = [[ABPersonMultiValueModel alloc] initWithLabelAndDictionary:Lable dictionary:multiValueDic];
	    	[mularray addObject:item];
		}
	}
	CFRelease(address);
	return mularray;
}

-(BOOL)loadFromABRecordRef:(ABRecordRef)recordref
{
	if (nil == recordref) 
    {
		return NO;
	}
	ABRecordRef abPerson = recordref;
    [self setRecordID:[NSNumber numberWithInt: ABRecordGetRecordID(abPerson)]];
    
    //[self setFullName:(__bridge NSString*)ABRecordCopyCompositeName(abPerson)];
    [self setFullName:CFBridgingRelease(ABRecordCopyCompositeName(abPerson))];

    [self setFirstName:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonFirstNameProperty]];
    [self setLastName:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonLastNameProperty]];
    [self setMiddleName:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonMiddleNameProperty]];
    [self setPrefix:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonPrefixProperty]];
    [self setSuffix:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonSuffixProperty]];
    [self setNickname:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonNicknameProperty]];
    [self setFirstNamePhonetic:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonFirstNamePhoneticProperty]];
    [self setMiddleNamePhonetic:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonMiddleNamePhoneticProperty]];
    [self setLastNamePhonetic:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonLastNamePhoneticProperty]];
    [self setCompany:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonOrganizationProperty]];
    [self setJob:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonJobTitleProperty]];
    [self setDepartment:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonDepartmentProperty]];
    [self setNote:[self getStringPropertyFromRecordRef:abPerson propertyId:kABPersonNoteProperty]];
    [self setBirthday:[self getDateTimePropertyFromRecordRef:abPerson propertyId:kABPersonBirthdayProperty]];
    [self setCreateDate:[self getDateTimePropertyFromRecordRef:abPerson propertyId:kABPersonCreationDateProperty]];
    [self setUpdateDate:[self getDateTimePropertyFromRecordRef:abPerson propertyId:kABPersonModificationDateProperty]];
    [self setPhones:[self getMultiStringPropertyFromRecordRef:abPerson propertyId:kABPersonPhoneProperty]];
    [self setEmails:[self getMultiStringPropertyFromRecordRef:abPerson propertyId:kABPersonEmailProperty]];
    [self setUrls:[self getMultiStringPropertyFromRecordRef:abPerson propertyId:kABPersonURLProperty]];
	[self setAddrs:[self getMultiDictionatyPropertyFromRecordRef:abPerson propertyId:kABPersonAddressProperty]];
    [self setIMs:[self getMultiDictionatyPropertyFromRecordRef:abPerson propertyId:kABPersonInstantMessageProperty]];
    [self setHeaderPhotoData:[self getPhotoImgFromRecordRef:abPerson]];

    //test
    //	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    //	NSString *documentsDirectory = [paths objectAtIndex:0];
    //	NSString *path = [documentsDirectory stringByAppendingFormat:@"/%d.png",self.m_RecordId];
    //	NSLog(@"NSSearchPathForDirectoriesInDomains = %@",path);
    //	[self.m_Photo writeToFile:path atomically:YES]; 
	
	self.abPersonState = AB_PERSON_STATE_DEFAULT;
	return YES;
}


-(id)initWithABRecordRef:(ABRecordRef)recordref
{
    self = [super init];
	if (self) 
	{
        [self loadFromABRecordRef:recordref];
	}
	return self;
}


#pragma mark public
//-(NSData*)getPhotoThumbnail
//{
//	ABAddressBookRef m_addressBook = ABAddressBookCreate();
//	ABRecordRef recordref = ABAddressBookGetPersonWithRecordID(m_addressBook,[self.recordID integerValue]);
//	if (nil == recordref) {
//		CFRelease(m_addressBook);
//		return Nil;
//	}
//    if (!ABPersonHasImageData(recordref))
//    {
//		CFRelease(m_addressBook);
//        return Nil;
//    }
//	NSData * Thumbnail = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(recordref,kABPersonImageFormatThumbnail);
//	CFRelease(m_addressBook);
//	return Thumbnail;
//}

-(NSData*)getSmallImage:(CGSize)size
{
    UIImage* image = [UIImage imageWithData:self.headerPhotoData];
    if (image != nil){
        UIImage* image1 = [image imageByScalingAndCroppingForSize:size];
        return UIImagePNGRepresentation(image1);
    }
    return nil;
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,%@   %@",self.firstName,self.lastName,self.phones];
}


@end
