//
//  Copyright (c) 2017 Google Inc.
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

import UIKit
import FirebaseAnalytics

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func logInAppPurchaseEvent() {
    // [START ecommerce_purchase]
    Analytics.logEvent(AnalyticsEventEcommercePurchase, parameters: [
      AnalyticsParameterCoupon: "SummerPromo",
      AnalyticsParameterCurrency: "JPY",
      AnalyticsParameterValue: 10000,
      AnalyticsParameterShipping: 500,
      AnalyticsParameterTransactionID: "192803301",
    ])
    // [END ecommerce_purchase]
  }

  func enhancedEcommerce() {
    // Implementation

    // [START create_items]
    // A pair of jeggings
    var jeggings: [String: Any] = [
      AnalyticsParameterItemID: "SKU_123",
      AnalyticsParameterItemName: "jeggings",
      AnalyticsParameterItemCategory: "pants",
      AnalyticsParameterItemVariant: "black",
      AnalyticsParameterItemBrand: "Google",
      AnalyticsParameterPrice: 9.99,
    ]

    // A pair of boots
    var boots: [String: Any] = [
      AnalyticsParameterItemID: "SKU_456",
      AnalyticsParameterItemName: "boots",
      AnalyticsParameterItemCategory: "shoes",
      AnalyticsParameterItemVariant: "brown",
      AnalyticsParameterItemBrand: "Google",
      AnalyticsParameterPrice: 24.99,
    ]

    // A pair of socks
    var socks: [String: Any] = [
      AnalyticsParameterItemID: "SKU_789",
      AnalyticsParameterItemName: "ankle_socks",
      AnalyticsParameterItemCategory: "socks",
      AnalyticsParameterItemVariant: "red",
      AnalyticsParameterItemBrand: "Google",
      AnalyticsParameterPrice: 5.99,
    ]
    // [END create_items]

    // Selecting a product from a list

    // [START view_item_list]
    // Add item indexes
    jeggings[AnalyticsParameterIndex] = 1
    boots[AnalyticsParameterIndex] = 2
    socks[AnalyticsParameterIndex] = 3

    // Prepare ecommerce parameters
    var itemList: [String: Any] = [
      AnalyticsParameterItemListID: "L001",
      AnalyticsParameterItemListName: "Related products",
    ]

    // Add items array
    itemList[AnalyticsParameterItems] = [jeggings, boots, socks]

    // Log view item list event
    Analytics.logEvent(AnalyticsEventViewItemList, parameters: itemList)
    // [END view_item_list]

    // [START select_item]
    // Prepare ecommerce parameters
    var selectedItem: [String: Any] = [
      AnalyticsParameterItemListID: "L001",
      AnalyticsParameterItemListName: "Related products",
    ]

    // Add items array
    selectedItem[AnalyticsParameterItems] = [jeggings]

    // Log select item event
    Analytics.logEvent(AnalyticsEventSelectItem, parameters: selectedItem)
    // [END select_item]

    // Viewing product details

    // [START view_product_details]
    // Prepare ecommerce parameters
    var productDetails: [String: Any] = [
      AnalyticsParameterCurrency: "USD",
      AnalyticsParameterValue: 9.99
    ]

    // Add items array
    productDetails[AnalyticsParameterItems] = [jeggings]

    // Log view item event
    Analytics.logEvent(AnalyticsEventViewItem, parameters: productDetails)
    // [END view_product_details]

    // Adding/Removing a product from shopping cart

    // [START add_to_cart_wishlist]
    // Specify order quantity
    jeggings[AnalyticsParameterQuantity] = 2

    // Prepare item detail params
    var itemDetails: [String: Any] = [
      AnalyticsParameterCurrency: "USD",
      AnalyticsParameterValue: 19.98
    ]

    // Add items
    itemDetails[AnalyticsParameterItems] = [jeggings]

    // Log an event when product is added to wishlist
    Analytics.logEvent(AnalyticsEventAddToWishlist, parameters: itemDetails)

    // Log an event when product is added to cart
    Analytics.logEvent(AnalyticsEventAddToCart, parameters: itemDetails)
    // [END add_to_cart_wishlist]

    // [START view_cart]
    // Specify order quantity
    jeggings[AnalyticsParameterQuantity] = 2
    boots[AnalyticsParameterQuantity] = 1

    // Prepare order parameters
    var orderParameters: [String: Any] = [
      AnalyticsParameterCurrency: "USD",
      AnalyticsParameterValue: 44.97
    ]

    // Add items array
    orderParameters[AnalyticsParameterItems] = [jeggings, boots]

    // Log event when cart is viewed
    Analytics.logEvent(AnalyticsEventViewCart, parameters: orderParameters)
    // [END view_cart]

    // [START remove_from_cart]
    // Specify removal quantity
    boots[AnalyticsParameterQuantity] = 1

    // Prepare params
    var removeParams: [String: Any] = [
      AnalyticsParameterCurrency: "USD",
      AnalyticsParameterValue: 24.99
    ]

    // Add items
    removeParams[AnalyticsParameterItems] = [boots]

    // Log removal event
    Analytics.logEvent(AnalyticsEventRemoveFromCart, parameters: removeParams)
    // [END remove_from_cart]

    // Initiating the checkout process

    // [START start_checkout]
    // Prepare checkout params
    var checkoutParams: [String: Any] = [
      AnalyticsParameterCurrency: "USD",
      AnalyticsParameterValue: 14.98,
      AnalyticsParameterCoupon: "SUMMER_FUN"
    ];

    // Add items
    checkoutParams[AnalyticsParameterItems] = [jeggings]

    // Log checkout event
    Analytics.logEvent(AnalyticsEventBeginCheckout, parameters: checkoutParams)
    // [END start_checkout]

    // [START add_shipping]
    // Prepare shipping params
    var shippingParams: [String: Any] = [
      AnalyticsParameterCurrency: "USD",
      AnalyticsParameterValue: 14.98,
      AnalyticsParameterCoupon: "SUMMER_FUN",
      AnalyticsParameterShippingTier: "Ground"
    ]

    // Add items
    shippingParams[AnalyticsParameterItems] = [jeggings]

    // Log added shipping info event
    Analytics.logEvent(AnalyticsEventAddShippingInfo, parameters: shippingParams)
    // [END add_shipping]

    // [START add_payment]
    // Prepare payment params
    var paymentParams: [String: Any] = [
      AnalyticsParameterCurrency: "USD",
      AnalyticsParameterValue: 14.98,
      AnalyticsParameterCoupon: "SUMMER_FUN",
      AnalyticsParameterPaymentType: "Visa"
    ]

    // Add items
    paymentParams[AnalyticsParameterItems] = [jeggings]

    // Log added payment info event
    Analytics.logEvent(AnalyticsEventAddPaymentInfo, parameters: paymentParams)
    // [END add_payment]

    // Making a purchase or issuing a refund

    // [START log_purchase]
    // Prepare purchase params
    var purchaseParams: [String: Any] = [
      AnalyticsParameterTransactionID: "T12345",
      AnalyticsParameterAffiliation: "Google Store",
      AnalyticsParameterCurrency: "USD",
      AnalyticsParameterValue: 14.98,
      AnalyticsParameterTax: 2.58,
      AnalyticsParameterShipping: 5.34,
      AnalyticsParameterCoupon: "SUMMER_FUN"
    ]

    // Add items
    purchaseParams[AnalyticsParameterItems] = [jeggings]

    // Log purchase event
    Analytics.logEvent(AnalyticsEventPurchase, parameters: purchaseParams)
    // [END log_purchase]

    // [START log_refund]
    // Prepare refund params
    var refundParams: [String: Any] = [
      AnalyticsParameterTransactionID: "T12345",
      AnalyticsParameterCurrency: "USD",
      AnalyticsParameterValue: 9.99,
    ]

    // (Optional) for partial refunds, define the item ID and quantity of refunded items
    let refundedProduct: [String: Any] = [
      AnalyticsParameterItemID: "SKU_123",
      AnalyticsParameterQuantity: 1,
    ];

    // Add items
    refundParams[AnalyticsParameterItems] = [refundedProduct]

    // Log refund event
    Analytics.logEvent(AnalyticsEventRefund, parameters: refundParams)
    // [END log_refund]

    // Applying promotions

    // [START apply_promo]
    // Prepare promotion parameters
    var promoParams: [String: Any] = [
      AnalyticsParameterPromotionID: "T12345",
      AnalyticsParameterPromotionName:"Summer Sale",
      AnalyticsParameterCreativeName: "summer2020_promo.jpg",
      AnalyticsParameterCreativeSlot: "featured_app_1",
      AnalyticsParameterLocationID: "HERO_BANNER",
    ]

    // Add items
    promoParams[AnalyticsParameterItems] = [jeggings]

    // Log event when promotion is displayed
    Analytics.logEvent(AnalyticsEventViewPromotion, parameters: promoParams)

    // Log event when promotion is selected
    Analytics.logEvent(AnalyticsEventSelectPromotion, parameters: promoParams)
    // [END apply_promo]
  }

}

