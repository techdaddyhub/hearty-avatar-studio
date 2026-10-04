------------------------------------
# Date: 10 October 2025

# Summary
- Forget password option added in admin log in page with database user & password validation
- Developed own Deeplinking function & removed branch.io completely for reducing the cost
- Some other optimisation & fixes
- Fake User Login via mobile device

#### Updated Files

- [README.md](README.md)

- [LoginController.php](app/Http/Controllers/LoginController.php)
- [NotificationController.php](app/Http/Controllers/NotificationController.php)
- [SettingController.php](app/Http/Controllers/SettingController.php)
- [UsersController.php](app/Http/Controllers/UsersController.php)

- [apexcharts.min.js](public/asset/bundles/apexcharts/apexcharts.min.js)
- [style.css](public/asset/css/style.css)

- [scripts.js](public/asset/js/scripts.js)
- [app.js](public/asset/script/app.js)
- [login.js](public/asset/script/login.js)
- [setting.js](public/asset/script/setting.js)

- [setting.blade.php](resources/views/setting.blade.php)
- [login.blade.php](resources/views/login/login.blade.php)

- [api.php](routes/api.php)
- [web.php](routes/web.php)

#### Added Files

- [appstore.png](public/asset/img/appstore.png)
- [playstore.png](public/asset/img/playstore.png)

- [apple-app-site-association](public/asset/apple-app-site-association)
- [assetlinks.json](public/asset/assetlinks.json)

- [ShareLinkPageController.php](app/Http/Controllers/ShareLinkPageController.php)
- [shareLinkPage.blade.php](resources/views/shareLinkPage.blade.php)

#### Deleted Files
None

#### Database

appdata : Fields added : play_store_download_link, app_store_download_link, uri_scheme 

admin_user : Fields added : created_at, updated_at
admin_user : Fields updated : user_id to id
 
------------------------------------

# Date: 14 August 2025

# Summary
- Subscriptions added for unlimited messages & reverse swipes & profile verification
- Matching function added
- Onboarding screens added
- Data collections, Interests, Religion, Relationship Goals, Languages known, Matching Preference added.
- User Location update added
- Localization in notification

#### Updated Files
[InterestController.php](app/Http/Controllers/InterestController.php)
[PostController.php](app/Http/Controllers/PostController.php)
[SettingController.php](app/Http/Controllers/SettingController.php)
[UsersController.php](app/Http/Controllers/UsersController.php)

[Constants.php](app/Models/Constants.php)
[GlobalFunction.php](app/Models/GlobalFunction.php)
[Users.php](app/Models/Users.php)

[style.css](public/asset/css/style.css)

[addfakeuser.js](public/asset/script/addfakeuser.js)
[app.js](public/asset/script/app.js)
[env.js](public/asset/script/env.js)
[index.js](public/asset/script/index.js)
[interest.js](public/asset/script/interest.js)
[setting.js](public/asset/script/setting.js)

[app.php](resources/lang/en/app.php)

[app.blade.php](resources/views/include/app.blade.php)

[addFakeUser.blade.php](resources/views/addFakeUser.blade.php)
[index.blade.php](resources/views/index.blade.php)
[interest.blade.php](resources/views/interest.blade.php)
[setting.blade.php](resources/views/setting.blade.php)
[viewLiveApplication.blade.php](resources/views/viewLiveApplication.blade.php)
[viewuser.blade.php](resources/views/viewuser.blade.php)

[api.php](routes/api.php)
[web.php](routes/web.php)

#### Added Files
[LanguageController.php](app/Http/Controllers/LanguageController.php)
[OnboardingScreenController.php](app/Http/Controllers/OnboardingScreenController.php)
[RelationshipGoalController.php](app/Http/Controllers/RelationshipGoalController.php)
[ReligionController.php](app/Http/Controllers/ReligionController.php)

[Language.php](app/Models/Language.php)
[OnboardingScreen.php](app/Models/OnboardingScreen.php)
[RelationshipGoal.php](app/Models/RelationshipGoal.php)
[Religion.php](app/Models/Religion.php)

[jquery-3.7.1.min.js](public/asset/js/jquery-3.7.1.min.js)

[language.js](public/asset/script/language.js)
[onboarding.js](public/asset/script/onboarding.js)
[relationshipGoal.js](public/asset/script/relationshipGoal.js)
[religion.js](public/asset/script/religion.js)

[languages.blade.php](resources/views/languages.blade.php)
[onboarding.blade.php](resources/views/onboarding.blade.php)
[relationshipGoals.blade.php](resources/views/relationshipGoals.blade.php)
[religions.blade.php](resources/views/religions.blade.php)

#### Deleted Files
[Gilroy-Heavy.ttf](public/asset/css/Gilroy-Heavy.ttf)
[Materialicons-Regular.html](public/asset/css/Materialicons-Regular.html)

#### Database
users : Fields name change : update_at to updated_at
users : Fields added : distance_preference, relationship_goal_id, religion_key, language_keys, dob, hidden_user_ids, country, state, city, app_language
users : Fields removed : age, live

appdata : Fields added : include_fake_user_in_matching, 

interests : Fields added : is_deleted, created_at, updated_at

onboarding_screens : new table
relationship_goals : new table
religions : new table
languages : new table


------------------------------------
# Date: 21 March 2025

## Summary
- Delete My Account code update
- Minor Bug fixes
- New Register user get free coins

#### Updated Files

- [LoginController.php](app/Http/Controllers/LoginController.php)
- [PostController.php](app/Http/Controllers/PostController.php)
- [UsersController.php](app/Http/Controllers/UsersController.php)
- [SettingController.php](app/Http/Controllers/SettingController.php)

- [env.js](public/asset/script/env.js)
- [verificationrequests.js](public/asset/script/verificationrequests.js)

- [app.php](resources/lang/en/app.php)

- [login.blade.php](resources/views/login/login.blade.php)
- [setting.blade.php](resources/views/setting.blade.php)

#### Added Files
None

#### Deleted Files
None

#### Database
appdata : Fields Added : new_user_free_coins

------------------------------------
# Date: 11 November 2024

## Summary
Fetch explore page data based on your preferences (Male, Female, or Both) and age preference.


#### Updated Files

- [UsersController.php](app/Http/Controllers/UsersController.php)
- [DiamondPackController.php](app/Http/Controllers/DiamondPackController.php)

- [diamondpacks.js](public/asset/script/diamondpacks.js)

- [diamondpacks.blade.php](resources/views/diamondpacks.blade.php)


#### Added Files
None

#### Deleted Files
None

#### Database
users : Fields Added : age_preferred_min, age_preferred_max, gender_preferred
diamond_packs : Fields Remove : price

------------------------------------
# Date: 28 October 2024

## Summary
Some bug fixes and improvement 
Notification issue solved

#### Updated Files

- [.env](.env)

- [DiamondPackController.php](app/Http/Controllers/DiamondPackController.php)
- [LiveApplicationController.php](app/Http/Controllers/LiveApplicationController.php)
- [NotificationController.php](app/Http/Controllers/NotificationController.php)
- [PostController.php](app/Http/Controllers/PostController.php)
- [RedeemRequestsController.php](app/Http/Controllers/RedeemRequestsController.php)
- [ReportController.php](app/Http/Controllers/ReportController.php)
- [SettingController.php](app/Http/Controllers/SettingController.php)
- [UsersController.php](app/Http/Controllers/UsersController.php)


#### Added Files
[LikedProfile.php](app/Models/LikedProfile.php)

#### Deleted Files
None

#### Database
like_profiles : New Table
user : fields remove : likedprofile
user_notification : fields remove :  post_id
user_notification : fields added :  item_id


------------------------------------
# Date: 15 October 2024

## Summary
- Change web admin panel title from setting
- Some other required changes for updates

#### Updated Files
- [UsersController.php](app/Http/Controllers/UsersController.php)
- [LoginController.php](app/Http/Controllers/LoginController.php)
- [SettingController.php](app/Http/Controllers/SettingController.php)

- [app.php](resources/lang/en/app.php)

- [setting.blade.php](resources/views/setting.blade.php)
- [app.blade.php](resources/views/include/app.blade.php)
- [login.blade.php](resources/views/login/login.blade.php)

#### Added Files
None

#### Deleted Files
None

#### Database
appdata : fields added :  app_name

------------------------------------

## Date: 27/06/2024  ##

--> Updated Files <--

app\Http\Controllers\SettingController.php
app\Http\Controllers\UsersController.php

public\asset\script\setting.js

resources\views\setting.blade.php

routes\api.php
routes\web.php

--> Database <--

admob : Remove table

________________________________________________________________________________

## Date: 13/06/2024  ##

--> Updated Files <--

.env
app\Http\Controllers\InterestController.php
app\Http\Controllers\LiveApplicationController.php
app\Http\Controllers\PostController.php
app\Http\Controllers\RedeemRequestsController.php
app\Http\Controllers\ReportController.php
app\Http\Controllers\SettingController.php
app\Http\Controllers\UsersController.php
app\Models\Constants.php
app\Models\GlobalFunction.php
app\Models\Story.php

public\asset\css\style.css

public\asset\script\env.js
public\asset\script\viewuser.js

resources\lang\en\app.php

resources\views\liveapplication.blade.php
resources\views\livehistory.blade.php
resources\views\redeemrequests.blade.php
resources\views\setting.blade.php
resources\views\viewuser.blade.php
resources\views\include\app.blade.php

routes\api.php
routes\web.php

--> Added Files <--

app\Class\AgoraDynamicKey\AccessToken.php
app\Class\AgoraDynamicKey\RtcTokenBuilder.php

resources\views\viewStories.blade.php

public\asset\script\story.js


--> Database <--

user_notification : fields renamed : myuser_id to my_user_id
users : fields added : likedprofile
app_data : fields added : post_description_limit, post_upload_image_limit, created_at, updated_at



## Date: 09/05/2024  ##

- From now, Update information will be provided in README.md File.
- No other changes in backed in this update.
- Remove file => update_info.txt



## Date: 30/04/2024  ##

--> Updated Files <--

app\Http\Controllers\DiamondPackController.php
app\Http\Controllers\InterestController.php
app\Http\Controllers\LiveApplicationController.php
app\Http\Controllers\LoginController.php
app\Http\Controllers\NotificationController.php
app\Http\Controllers\PackageController.php
app\Http\Controllers\PagesController.php
app\Http\Controllers\PostController.php
app\Http\Controllers\RedeemRequestsController.php
app\Http\Controllers\ReportController.php
app\Http\Controllers\SettingController.php
app\Http\Controllers\UsersController.php

app\Models\Users.php
app\Models\UserNotification.php

public\asset\css\style.css

public\asset\js\scripts.js

public\asset\script\addfakeuser.js
public\asset\script\app.js
public\asset\script\diamondpacks.js
public\asset\script\env.js
public\asset\script\gifts.js
public\asset\script\interest.js
public\asset\script\liveApplication.js
public\asset\script\login.js
public\asset\script\notification.js
public\asset\script\package.js
public\asset\script\redeemRequests.js
public\asset\script\report.js
public\asset\script\setting.js
public\asset\script\users.js
public\asset\script\verificationrequests.js
public\asset\script\viewLiveApplication.js
public\asset\script\viewuser.js

resources\lang\en\app.php

resources\views\include\app.blade.php

resources\views\addFakeUser.blade.php
resources\views\diamondpacks.blade.php
resources\views\gifts.blade.php
resources\views\index.blade.php
resources\views\interest.blade.php
resources\views\liveapplication.blade.php
resources\views\livehistory.blade.php
resources\views\notifications.blade.php
resources\views\package.blade.php
resources\views\redeemrequests.blade.php
resources\views\report.blade.php
resources\views\setting.blade.php
resources\views\users.blade.php
resources\views\verificationrequests.blade.php
resources\views\viewLiveApplication.blade.php
resources\views\viewuser.blade.php


routes\api.php
routes\web.php

.env


-----------------------------------------------------

--> Added Files <--

app\Models\AppData.php
app\Models\Comment.php
app\Models\Constants.php
app\Models\FollowingList.php
app\Models\GlobalFunction.php
app\Models\Like.php
app\Models\PostContent.php
app\Models\Story.php

public\asset\css\bootstrap.min.css

public\asset\img\check-circle.svg
public\asset\img\x.svg
public\asset\img\favicon.png

public\asset\js\bootstrap.min.js

public\asset\script\post.js

resources\views\posts.blade.php

-----------------------------------------------------

--> Added Folder <--

public\asset\font\scandia

-----------------------------------------------------

--> Database <--

appdata : fields added : is_social_media
comments : new table
likes : new table
posts : new table
post_contents : new table
reports : fields added : type, post_id, created_at, updated_at
reports : fields removed : contact,
stories : new table
users : fields added : username, following, followers,created_at, updated_at
users : fields removed : likedprofile
user_notification : remove field : data_user_id
user_notification : add field : my_user_id, post_id