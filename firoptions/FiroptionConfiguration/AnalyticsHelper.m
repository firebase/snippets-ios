//
//  Copyright (c) 2020 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

@import Firebase;

#import "AnalyticsHelper.h"

@implementation AnalyticsHelper

- (void)logInAppPurchase {
  // [START ecommerce_purchase]
  [FIRAnalytics logEventWithName:kFIREventEcommercePurchase
                      parameters:@{
    kFIRParameterCoupon: @"SummerPromo",
    kFIRParameterCurrency: @"JPY",
    kFIRParameterValue: @10000,
    kFIRParameterShipping: @500,
    kFIRParameterTransactionID: @"192803301",
  }];
  // [END ecommerce_purchase]
}

- (void)enhancedEcommerce {
  // Implementation

  // [START create_items]
  // A pair of jeggings
  NSMutableDictionary *jeggings = [@{
    kFIRParameterItemID: @"SKU_123",
    kFIRParameterItemName: @"jeggings",
    kFIRParameterItemCategory: @"pants",
    kFIRParameterItemVariant: @"black",
    kFIRParameterItemBrand: @"Google",
    kFIRParameterPrice: @9.99,
  } mutableCopy];

  // A pair of boots
  NSMutableDictionary *boots = [@{
    kFIRParameterItemID: @"SKU_456",
    kFIRParameterItemName: @"boots",
    kFIRParameterItemCategory: @"shoes",
    kFIRParameterItemVariant: @"brown",
    kFIRParameterItemBrand: @"Google",
    kFIRParameterPrice: @24.99,
  } mutableCopy];

  // A pair of socks
  NSMutableDictionary *socks = [@{
    kFIRParameterItemID: @"SKU_789",
    kFIRParameterItemName: @"ankle_socks",
    kFIRParameterItemCategory: @"socks",
    kFIRParameterItemVariant: @"red",
    kFIRParameterItemBrand: @"Google",
    kFIRParameterPrice: @5.99,
  } mutableCopy];
  // [END create_items]

  // Selecting a product from a list

  // [START view_item_list]
  // Add item indexes
  jeggings[kFIRParameterIndex] = @1;
  boots[kFIRParameterIndex] = @2;
  socks[kFIRParameterIndex] = @3;

  // Prepare ecommerce parameters
  NSMutableDictionary *itemList = [@{
    kFIRParameterItemListID: @"L001",
    kFIRParameterItemListName: @"Related products",
  } mutableCopy];

  // Add items array
  itemList[kFIRParameterItems] = @[jeggings, boots, socks];

  // Log view item list event
  [FIRAnalytics logEventWithName:kFIREventViewItemList parameters:itemList];
  // [END view_item_list]

  // [START select_item]
  // Prepare ecommerce parameters
  NSMutableDictionary *selectedItem = [@{
    kFIRParameterItemListID: @"L001",
    kFIRParameterItemListName: @"Related products",
  } mutableCopy];

  // Add items array
  selectedItem[kFIRParameterItems] = @[jeggings];

  // Log select item event
  [FIRAnalytics logEventWithName:kFIREventSelectItem parameters:selectedItem];
  // [END select_item]

  // Viewing product details

  // [START view_product_details]
  // Prepare ecommerce parameters
  NSMutableDictionary *productDetails = [@{
    kFIRParameterCurrency: @"USD",
    kFIRParameterValue: @9.99
  } mutableCopy];

  // Add items array
  productDetails[kFIRParameterItems] = @[jeggings];

  // Log view item event
  [FIRAnalytics logEventWithName:kFIREventViewItem parameters:productDetails];
  // [END view_product_details]

  // Adding/Removing a product from shopping cart

  // [START add_to_cart_wishlist]
  // Specify order quantity
  jeggings[kFIRParameterQuantity] = @2;

  // Prepare item detail params
  NSMutableDictionary *itemDetails = [@{
    kFIRParameterCurrency: @"USD",
    kFIRParameterValue: @19.98
  } mutableCopy];

  // Add items
  itemDetails[kFIRParameterItems] = @[jeggings];

  // Log an event when product is added to wishlist
  [FIRAnalytics logEventWithName:kFIREventAddToWishlist parameters:itemDetails];

  // Log an event when product is added to cart
  [FIRAnalytics logEventWithName:kFIREventAddToCart parameters:itemDetails];
  // [END add_to_cart_wishlist]

  // [START view_cart]
  // Specify order quantity
  jeggings[kFIRParameterQuantity] = @2;
  boots[kFIRParameterQuantity] = @1;

  // Prepare order parameters
  NSMutableDictionary *orderParameters = [@{
    kFIRParameterCurrency: @"USD",
    kFIRParameterValue: @44.97
  } mutableCopy];

  // Add items array
  orderParameters[kFIRParameterItems] = @[jeggings, boots];

  // Log event when cart is viewed
  [FIRAnalytics logEventWithName:kFIREventViewCart parameters:orderParameters];
  // [END view_cart]

  // [START remove_from_cart]
  // Specify removal quantity
  boots[kFIRParameterQuantity] = @1;

  // Prepare params
  NSMutableDictionary *removeParams = [@{
    kFIRParameterCurrency: @"USD",
    kFIRParameterValue: @24.99
  } mutableCopy];

  // Add items
  removeParams[kFIRParameterItems] = @[boots];

  // Log removal event
  [FIRAnalytics logEventWithName:kFIREventRemoveFromCart parameters:removeParams];
  // [END remove_from_cart]

  // Initiating the checkout process

  // [START start_checkout]
  // Prepare checkout params
  NSMutableDictionary *checkoutParams = [@{
    kFIRParameterCurrency: @"USD",
    kFIRParameterValue: @14.98,
    kFIRParameterCoupon: @"SUMMER_FUN"
  } mutableCopy];

  // Add items
  checkoutParams[kFIRParameterItems] = @[jeggings];

  // Log checkout event
  [FIRAnalytics logEventWithName:kFIREventBeginCheckout parameters:checkoutParams];
  // [END start_checkout]

  // [START add_shipping]
  // Prepare shipping params
  NSMutableDictionary *shippingParams = [@{
    kFIRParameterCurrency: @"USD",
    kFIRParameterValue: @14.98,
    kFIRParameterCoupon: @"SUMMER_FUN",
    kFIRParameterShippingTier: @"Ground"
  } mutableCopy];

  // Add items
  shippingParams[kFIRParameterItems] = @[jeggings];

  // Log added shipping info event
  [FIRAnalytics logEventWithName:kFIREventAddShippingInfo parameters:shippingParams];
  // [END add_shipping]

  // [START add_payment]
  // Prepare payment params
  NSMutableDictionary *paymentParams = [@{
    kFIRParameterCurrency: @"USD",
    kFIRParameterValue: @14.98,
    kFIRParameterCoupon: @"SUMMER_FUN",
    kFIRParameterPaymentType: @"Visa"
  } mutableCopy];

  // Add items
  paymentParams[kFIRParameterItems] = @[jeggings];

  // Log added payment info event
  [FIRAnalytics logEventWithName:kFIREventAddPaymentInfo parameters:paymentParams];
  // [END add_payment]

  // Making a purchase or issuing a refund

  // [START log_purchase]
  // Prepare purchase params
  NSMutableDictionary *purchaseParams = [@{
    kFIRParameterTransactionID: @"T12345",
    kFIRParameterAffiliation: @"Google Store",
    kFIRParameterCurrency: @"USD",
    kFIRParameterValue: @14.98,
    kFIRParameterTax: @2.58,
    kFIRParameterShipping: @5.34,
    kFIRParameterCoupon: @"SUMMER_FUN"
  } mutableCopy];

  // Add items
  purchaseParams[kFIRParameterItems] = @[jeggings];

  // Log purchase event
  [FIRAnalytics logEventWithName:kFIREventPurchase parameters:purchaseParams];
  // [END log_purchase]

  // [START log_refund]
  // Prepare refund params
  NSMutableDictionary *refundParams = [@{
    kFIRParameterTransactionID: @"T12345",
    kFIRParameterCurrency: @"USD",
    kFIRParameterValue: @9.99,
  } mutableCopy];

  // (Optional) for partial refunds, define the item ID and quantity of refunded items
  NSDictionary *refundedProduct = @{
    kFIRParameterItemID: @"SKU_123",
    kFIRParameterQuantity: @1,
  };

  // Add items
  refundParams[kFIRParameterItems] = @[refundedProduct];

  // Log refund event
  [FIRAnalytics logEventWithName:kFIREventRefund parameters:refundParams];
  // [END log_refund]

  // Applying promotions

  // [START apply_promo]
  // Prepare promotion parameters
  NSMutableDictionary *promoParams = [@{
    kFIRParameterPromotionID: @"T12345",
    kFIRParameterPromotionName:@"Summer Sale",
    kFIRParameterCreativeName: @"summer2020_promo.jpg",
    kFIRParameterCreativeSlot: @"featured_app_1",
    kFIRParameterLocationID: @"HERO_BANNER",
  } mutableCopy];

  // Add items
  promoParams[kFIRParameterItems] = @[jeggings];

  // Log event when promotion is displayed
  [FIRAnalytics logEventWithName:kFIREventViewPromotion parameters:promoParams];

  // Log event when promotion is selected
  [FIRAnalytics logEventWithName:kFIREventSelectPromotion parameters:promoParams];
  // [END apply_promo]
}

@end
