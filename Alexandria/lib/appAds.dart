import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;

import 'consttants.dart';

String? getBannerAdUnitId() {
  if (Platform.isIOS) {
    return bannerIOS;
  } else if (Platform.isAndroid) {
    return bannerAndroid;
  }
  return null;
}

String bannerIOS = '';
String bannerAndroid = '';
String interstitialAndroid = '';
String interstitialIOS = '';
String openAdIdAndroid = '';
String openAdIdIOS = '';
InterstitialAd? interstitialAd;
bool openAdLoad = false;
AppOpenAd? appOpenAd;
// bool isShowingAd = false;

getAdData() async {
  MobileAds.instance.initialize();
  MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ['85bb6acd334c088abe4496690a37d2d2']));
  try {
    final response = await http.get(Uri.parse(apiLink + 'api.php?method_name=app_details'));
    if (response.statusCode == 200) {
      var finalResponse = jsonDecode(response.body);
      bannerIOS = finalResponse['EBOOK_APP'][0]['banner_ad_id_ios'];
      bannerAndroid = finalResponse['EBOOK_APP'][0]['banner_ad_id'];
      interstitialAndroid = finalResponse['EBOOK_APP'][0]['interstital_ad_id'];
      interstitialIOS = finalResponse['EBOOK_APP'][0]['interstital_ad_id_ios'];
      openAdIdAndroid = finalResponse['EBOOK_APP'][0]['app_open_ad_id'];
      openAdIdIOS = finalResponse['EBOOK_APP'][0]['ios_app_open_ad_id'];
      privacypolicy = finalResponse['EBOOK_APP'][0]["app_privacy_policy"];
    } else {
      print("Response of body ==${null}");
    }

    AdmobAds().loadAppOpenAd();
    AdmobAds().createInterstitialAd();
    AdmobAds().bannerAds();
  } catch (e) {
    print('error in get data $e');
  }
}

String? intersTitleAd() {
  if (Platform.isIOS) {
    return interstitialIOS;
  } else if (Platform.isAndroid) {
    return interstitialAndroid;
    // return "ca-app-pub-3940256099942544/1033173712";
  }
  return null;
}

String? openAd() {
  if (Platform.isIOS) {
    return openAdIdIOS;
  } else if (Platform.isAndroid) {
    return openAdIdAndroid;
  }
  return null;
}

class AdmobAds {
  Widget bannerAds() {
    final googleBannerAd =BannerAd(
      adUnitId: getBannerAdUnitId()!,
      size: AdSize.banner,
      listener: const BannerAdListener(),
      request: AdRequest(),
    )..load();
    return  getBannerAdUnitId()!= null && getBannerAdUnitId()!.isNotEmpty ?  Container(
      alignment: Alignment.center,
      width: googleBannerAd.size.width.toDouble(),
      height: googleBannerAd.size.height.toDouble(),
      child: AdWidget(ad: googleBannerAd),
    ) :  SizedBox();
  }

  loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: openAd()!, //Your ad Id from admob
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(onAdLoaded: (ad) {
        appOpenAd = ad;
        openAdLoad = true;
        print('open add loaded $openAdLoad');
      }, onAdFailedToLoad: (error) {
        print('adds benner errorr  ====> ${error.message}');
        print('adds benner errorr all ====> ${error}');
      }),
    );
  }

  /// Interstitial Ads

  int maxFailedLoadAttempts = 3;

  static AdRequest request = const AdRequest(
    keywords: ['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  InterstitialAd? createInterstitialAd() {
    try {
      InterstitialAd.load(
          adUnitId: intersTitleAd()!,
          request: request,
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              interstitialAd = ad;
              print('add loaded');
              // _interstitialAd = ad;
            },
            onAdFailedToLoad: (LoadAdError error) {
              print('add loaded error $error');
            },
          ));
    } catch (e) {
      print('add loaded error $e');
    }
    return null;
  }

  /// Show IntertitialAd
  void showInterstitialAd() {
    if (interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');

        ad.dispose();

        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');

        ad.dispose();

        createInterstitialAd();
      },
    );
    interstitialAd!.show();

    interstitialAd = null;
  }
}
