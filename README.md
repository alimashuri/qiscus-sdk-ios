Qiscus SDK [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/qiscus-sdk-ios.svg)](https://img.shields.io/cocoapods/v/qiscus-sdk-ios.svg)
======
<p align="center"><img src="https://github.com/qiscus/qiscus-sdk-android/raw/develop/screenshot/device-2016-09-16-102736.png" width="40%" /><img src="https://github.com/qiscus/qiscus-sdk-android/raw/develop/screenshot/device-2016-09-16-102923.png" width="40%" /></p>
Qiscus SDK is a lightweight and powerful android chat library. Qiscus SDK will allow you to easily integrating Qiscus engine with your apps to make cool chatting application.

## Requirements

- iOS 9.0+ 
- Xcode 8.0+
- Swift 2.0+

# Instalation
### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```
> CocoaPods 1.1.0+ is required.

To integrate Qiscus into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'qiscus-sdk-ios'
end
```

# Let's make cools chatting apps!
#### Init Qiscus
Init Qiscus at your application class with your application ID, you can get app ID here [http://sdk.qiscus.com](http://sdk.qiscus.com)
```java
public class SampleApps extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        Qiscus.init(this, "yourQiscusAppId");
    }
}
```
#### Login to Qiscus engine
Before user can start chatting each other, they must login to qiscus engine.
```java
Qiscus.setUser("user@email.com", "userKey")
      .withUsername("Tony Stark")
      .withAvatarUrl("http://avatar.url.com/handsome.jpg")
      .save(new Qiscus.SetUserListener() {
          @Override
          public void onSuccess(QiscusAccount qiscusAccount) {
              DataManager.saveQiscusAccount(qiscusAccount);
              startActivity(new Intent(this, ConsultationListActivity.class));
          }
          @Override
          public void onError(Throwable throwable) {
              throwable.printStackTrace();
              showError(throwable.getMessage());
          }
      });
```
### Start the chatting
```java
Qiscus.buildChatWith("jhon.doe@gmail.com")
      .withTitle("Jhon Doe")
      .build(this, new Qiscus.ChatActivityBuilderListener() {
          @Override
          public void onSuccess(Intent intent) {
              startActivity(intent);
          }
          @Override
          public void onError(Throwable throwable) {
              throwable.printStackTrace();
              showError(throwable.getMessage());
          }
      });
```
### Customize the chat UI
Boring with default template? You can customized it, try it!, we have more items than those below code, its just example.
```java
Qiscus.getChatConfig()
      .setStatusBarColor(R.color.blue)
      .setAppBarColor(R.color.red)
      .setTitleColor(R.color.white)
      .setLeftBubbleColor(R.color.green)
      .setRightBubbleColor(R.color.yellow)
      .setRightBubbleTextColor(R.color.white)
      .setRightBubbleTimeColor(R.color.grey)
      .setTimeFormat(date -> new SimpleDateFormat("HH:mm").format(date));
```
### Advanced Chat Customizing
Check [CustomChatActivity.java](https://github.com/qiscus/qiscus-sdk-android/blob/develop/app/src/main/java/com/qiscus/dragonfly/CustomChatActivity.java)
<p align="center"><img src="https://github.com/qiscus/qiscus-sdk-android/raw/develop/screenshot/device-2016-09-28-232326.png" width="33%" /><img src="https://github.com/qiscus/qiscus-sdk-android/raw/develop/screenshot/device-2016-09-28-232535.png" width="33%" /><img src="https://github.com/qiscus/qiscus-sdk-android/raw/develop/screenshot/device-2016-09-28-232714.png" width="33%" /></p>
### RxJava Support
```java
// Setup qiscus account with rxjava example
Qiscus.setUser("user@email.com", "password")
      .withUsername("Tony Stark")
      .withAvatarUrl("http://avatar.url.com/handsome.jpg")
      .save()
      .subscribeOn(Schedulers.io())
      .observeOn(AndroidSchedulers.mainThread())
      .subscribe(qiscusAccount -> {
          DataManager.saveQiscusAccount(qiscusAccount);
          startActivity(new Intent(this, ConsultationListActivity.class));
      }, throwable -> {
          throwable.printStackTrace();
          showError(throwable.getMessage());
      });

// Start a chat activity with rxjava example      
Qiscus.buildChatWith("jhon.doe@gmail.com")
      .withTitle("Jhon Doe")
      .build(this)
      .subscribeOn(Schedulers.io())
      .observeOn(AndroidSchedulers.mainThread())
      .subscribe(intent -> {
          startActivity(intent);
      }, throwable -> {
          throwable.printStackTrace();
          showError(throwable.getMessage());
      });
```

Check sample apps -> [DragonFly](https://github.com/qiscus/qiscus-sdk-android-sample)

## License

Qiscus-SDK-IOS is released under the MIT license. See LICENSE for details.
