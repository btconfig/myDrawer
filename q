diff --git a/css/style.css b/css/style.css
index fe59500..1d09d31 100755
--- a/css/style.css
+++ b/css/style.css
@@ -1,6 +1,16 @@
 * {
 	color: darkslategrey;
 }
+/**
+ * overall
+ */
+.content {
+	padding-top: 44px;
+	text-align: left;
+}
+/**
+ * css of containers
+ */
 .headerContainer {
 	background-color:#f1f1f1; 
 	height: 50px; 
@@ -17,3 +27,20 @@
 	background-color: #f1f1f1; 
 	text-align: center; 
 }
+
+/**
+ * list.html
+ */
+.list-table-img {
+	height: 100px;
+}
+.list-table-description {
+	vertical-align: top;
+}
+/**
+ * newItem.html
+ */
+.newItem-addImg {
+	width: 100%; 
+	border: 1px solid #f1f1f1;
+}
diff --git a/index.html b/index.html
index f0ecb94..adc1c7f 100755
--- a/index.html
+++ b/index.html
@@ -13,7 +13,7 @@
 </head>
 <body ng-app="myDrawerApp">
 	<header id="header" ng-controller="mainCtrl">
-		<div id="back" ng-class="{'iback':ifNewItemState}" class="nvbt" ng-click="listItem()"></div>
+		<div id="back" ng-class="{'iback':ifNewItemState}" class="nvbt" ng-click="goTolistPage()"></div>
 		<div class="nvtt">My Drawer</div>
 		<div class="nvbt" ng-show="!ifNewItemState" ng-click="addNewItem()">+</div>
 	</header>
diff --git a/js/app.js b/js/app.js
index 5a0a2d0..1180475 100755
--- a/js/app.js
+++ b/js/app.js
@@ -1,28 +1,79 @@
 var myDrawerApp = angular.module('myDrawerApp', ['ui.router']);
 
-myDrawerApp.controller('mainCtrl', ['$scope', '$state', function($scope,$state) {
+/**
+ * app service
+ */
+myDrawerApp.service('drawerService', ['$rootScope', '$interval', function($rootScope,$interval) {
+	var serviceFunc = {};
+	
+	// service functions
+	serviceFunc.updateList = function() {
+		var listLen = plus.storage.getLength();
+		for(var i = 0; i < listLen; i ++) {
+			var keyName = plus.storage.key(i);
+			var valueObj = plus.storage.getItem(keyName);
+			var value = JSON.parse(valueObj);
+			$rootScope.itemList.push(value);
+		}
+	};
+	
+	// service initialization
+	var stop = $interval(function() {
+		if(window.plus){
+			$rootScope.itemList = [];
+			serviceFunc.updateList();
+			$interval.cancel(stop);
+		}
+	}, 100);
+	
+	return serviceFunc;
+}]);
+
+/**
+ * main controller
+ */
+myDrawerApp.controller('mainCtrl', ['$scope', '$state', 'drawerService', function($scope,$state,drawerService) {
 	$scope.ifNewItemState = false;
 	$scope.addNewItem = function () {
 		$state.go('newItem');
 		$scope.ifNewItemState = true;
-	}
-	$scope.listItem = function () {
+	};
+	$scope.goTolistPage = function () {
 		$state.go('list');
 		$scope.ifNewItemState = false;
-	}
+	};
+}]);
+
+/**
+ * list controller
+ */
+myDrawerApp.controller('listCtrl',['$scope', 'drawerService',function($scope,drawerService) {
 }]);
 
-myDrawerApp.controller('listCtrl',['$scope' ,function($scope) {
-	$scope.picList = [];
-	$scope.hello = function () {
-		alert('hello');
+/**
+ * new item controller
+ */
+myDrawerApp.controller('newItemCtrl', ['$scope', 'drawerService', function($scope, drawerService) {
+	$scope.newItem = {
+		"description": ""
 	};
-	// 拍照
+	// take a photo
 	$scope.getImage = function() {
 		var cmr = plus.camera.getCamera();
 		cmr.captureImage( function ( p ) {
 			plus.io.resolveLocalFileSystemURL( p, function ( entry ) {
-				$scope.picList.push(entry.toLocalURL());
+				var dateObj = new Date();
+				$scope.newItem.date = dateObj.getFullYear() + '-'
+									  	+ (dateObj.getMonth() + 1) + '-'
+									  	+ dateObj.getDate() + ' '
+									  	+ dateObj.getHours() + ':'
+									  	+ dateObj.getMinutes() + ':'
+									  	+ dateObj.getSeconds();
+				$scope.newItem.picPath = entry.toLocalURL();
+				var keyName = $scope.newItem.date;
+				var value = JSON.stringify($scope.newItem);
+				plus.storage.setItem(keyName, value);
+				drawerService.updateList();
 			}, function ( e ) {
 				console.log( "读取拍照文件错误："+e.message );
 			} );
@@ -32,12 +83,9 @@ myDrawerApp.controller('listCtrl',['$scope' ,function($scope) {
 	};
 }]);
 
-myDrawerApp.controller('newItemCtrl', ['$scope', function($scope) {
-	$scope.newItem = {
-		"description": "hello"
-	};
-}]);
-
+/**
+ * app route state
+ */
 myDrawerApp.config(function($stateProvider, $urlRouterProvider) {
 	// For any unmatched url, redirect to /state1
   	$urlRouterProvider.otherwise('/list');
diff --git a/manifest.json b/manifest.json
index f9ae5b8..11bd284 100755
--- a/manifest.json
+++ b/manifest.json
@@ -137,36 +137,36 @@
                     "prerendered": true, /*应用图标是否已经高亮处理，在iOS6及以下设备上有效*/
                     "auto": "", /*应用图标，分辨率：512x512，用于自动生成各种尺寸程序图标*/
                     "iphone": {
-                        "normal": "", /*iPhone3/3GS程序图标，分辨率：57x57*/
-                        "retina": "", /*iPhone4程序图标，分辨率：114x114*/
-                        "retina7": "", /*iPhone4S/5/6程序图标，分辨率：120x120*/
-			"retina8": "", /*iPhone6 Plus程序图标，分辨率：180x180*/
-                        "spotlight-normal": "", /*iPhone3/3GS Spotlight搜索程序图标，分辨率：29x29*/
-                        "spotlight-retina": "", /*iPhone4 Spotlight搜索程序图标，分辨率：58x58*/
-                        "spotlight-retina7": "", /*iPhone4S/5/6 Spotlight搜索程序图标，分辨率：80x80*/
-                        "settings-normal": "", /*iPhone4设置页面程序图标，分辨率：29x29*/
-                        "settings-retina": "", /*iPhone4S/5/6设置页面程序图标，分辨率：58x58*/
-			"settings-retina8": "" /*iPhone6Plus设置页面程序图标，分辨率：87x87*/
+                        "normal": "unpackage/res/icons/57x57.png", /*iPhone3/3GS程序图标，分辨率：57x57*/
+                        "retina": "unpackage/res/icons/114x114.png", /*iPhone4程序图标，分辨率：114x114*/
+                        "retina7": "unpackage/res/icons/120x120.png", /*iPhone4S/5/6程序图标，分辨率：120x120*/
+			"retina8": "unpackage/res/icons/180x180.png", /*iPhone6 Plus程序图标，分辨率：180x180*/
+                        "spotlight-normal": "unpackage/res/icons/29x29.png", /*iPhone3/3GS Spotlight搜索程序图标，分辨率：29x29*/
+                        "spotlight-retina": "unpackage/res/icons/58x58.png", /*iPhone4 Spotlight搜索程序图标，分辨率：58x58*/
+                        "spotlight-retina7": "unpackage/res/icons/80x80.png", /*iPhone4S/5/6 Spotlight搜索程序图标，分辨率：80x80*/
+                        "settings-normal": "unpackage/res/icons/29x29.png", /*iPhone4设置页面程序图标，分辨率：29x29*/
+                        "settings-retina": "unpackage/res/icons/58x58.png", /*iPhone4S/5/6设置页面程序图标，分辨率：58x58*/
+			"settings-retina8": "unpackage/res/icons/87x87.png" /*iPhone6Plus设置页面程序图标，分辨率：87x87*/
                     },
                     "ipad": {
-                        "normal": "", /*iPad普通屏幕程序图标，分辨率：72x72*/
-                        "retina": "", /*iPad高分屏程序图标，分辨率：144x144*/
-                        "normal7": "", /*iPad iOS7程序图标，分辨率：76x76*/
-                        "retina7": "", /*iPad iOS7高分屏程序图标，分辨率：152x152*/
-                        "spotlight-normal": "", /*iPad Spotlight搜索程序图标，分辨率：50x50*/
-                        "spotlight-retina": "", /*iPad高分屏Spotlight搜索程序图标，分辨率：100x100*/
-                        "spotlight-normal7": "",/*iPad iOS7 Spotlight搜索程序图标，分辨率：40x40*/
-                        "spotlight-retina7": "",/*iPad iOS7高分屏Spotlight搜索程序图标，分辨率：80x80*/
-                        "settings-normal": "",/*iPad设置页面程序图标，分辨率：29x29*/
-                        "settings-retina": "" /*iPad高分屏设置页面程序图标，分辨率：58x58*/
+                        "normal": "unpackage/res/icons/72x72.png", /*iPad普通屏幕程序图标，分辨率：72x72*/
+                        "retina": "unpackage/res/icons/144x144.png", /*iPad高分屏程序图标，分辨率：144x144*/
+                        "normal7": "unpackage/res/icons/76x76.png", /*iPad iOS7程序图标，分辨率：76x76*/
+                        "retina7": "unpackage/res/icons/152x152.png", /*iPad iOS7高分屏程序图标，分辨率：152x152*/
+                        "spotlight-normal": "unpackage/res/icons/50x50.png", /*iPad Spotlight搜索程序图标，分辨率：50x50*/
+                        "spotlight-retina": "unpackage/res/icons/100x100.png", /*iPad高分屏Spotlight搜索程序图标，分辨率：100x100*/
+                        "spotlight-normal7": "unpackage/res/icons/40x40.png",/*iPad iOS7 Spotlight搜索程序图标，分辨率：40x40*/
+                        "spotlight-retina7": "unpackage/res/icons/80x80.png",/*iPad iOS7高分屏Spotlight搜索程序图标，分辨率：80x80*/
+                        "settings-normal": "unpackage/res/icons/29x29.png",/*iPad设置页面程序图标，分辨率：29x29*/
+                        "settings-retina": "unpackage/res/icons/58x58.png" /*iPad高分屏设置页面程序图标，分辨率：58x58*/
                     }
                 },
                 "android": {
-                    "mdpi": "", /*普通屏程序图标，分辨率：48x48*/
-                    "ldpi": "", /*大屏程序图标，分辨率：48x48*/
-                    "hdpi": "", /*高分屏程序图标，分辨率：72x72*/
-                    "xhdpi": "",/*720P高分屏程序图标，分辨率：96x96*/
-                    "xxhdpi": ""/*1080P 高分屏程序图标，分辨率：144x144*/
+                    "mdpi": "unpackage/res/icons/48x48.png", /*普通屏程序图标，分辨率：48x48*/
+                    "ldpi": "unpackage/res/icons/48x48.png", /*大屏程序图标，分辨率：48x48*/
+                    "hdpi": "unpackage/res/icons/72x72.png", /*高分屏程序图标，分辨率：72x72*/
+                    "xhdpi": "unpackage/res/icons/96x96.png",/*720P高分屏程序图标，分辨率：96x96*/
+                    "xxhdpi": "unpackage/res/icons/144x144.png"/*1080P 高分屏程序图标，分辨率：144x144*/
                 }
             },
             "splashscreen": {
diff --git a/templates/list.html b/templates/list.html
index a919239..bab6bcf 100755
--- a/templates/list.html
+++ b/templates/list.html
@@ -1,8 +1,12 @@
 <div id="content" class="content">
-	<div>item list</div>
-	<ul>                                                    
-		<li ng-repeat="pic in picList track by $index">     
-			<img src="pic" />                               
-		</li>                                               
-	</ul>                                                   
-</div>                                                      
\ No newline at end of file
+	<table>
+		<tr ng-repeat="item in itemList track by $index">
+			<td>
+				<img class="list-table-img" ng-src="{{item.picPath}}" />			
+			</td>
+			<td class="list-table-description">
+				<p style="padding: 0; margin: 0;">{{item.date}}</p>
+			</td>
+		</tr>
+	</table>
+</div>
\ No newline at end of file
diff --git a/templates/newItem.html b/templates/newItem.html
index 2f37d2d..68cff86 100755
--- a/templates/newItem.html
+++ b/templates/newItem.html
@@ -1,5 +1,15 @@
 <div id="content" class="content">
-	<textarea style="resize: none;"
-		ng-model="newItem.description"></textarea>
-	<img src="./img/plus.png" style="width: 100%; border: 1px solid #f1f1f1;" alt="添加图片"/>
+	<table style="width: 100%;">
+		<tr>
+			<td style="border-bottom:1px solid #F1F1F1;padding: 5px;">
+				<textarea ng-model="newItem.description" style="border: none;resize: none;width: 100%;"></textarea>
+			</td>
+		</tr>
+		<tr>
+			<td style="padding: 5px;">
+				<img ng-click="getImage()" style="width: 100%;"
+					src="./img/plus.png" class="newItem-addImg" alt="添加图片"/>
+			</td>
+		</tr>
+	</table>
 </div>
