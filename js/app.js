var myDrawerApp = angular.module('myDrawerApp', ['ui.router']);

/**
 * app service
 */
myDrawerApp.service('drawerService', ['$rootScope', '$interval', function($rootScope, $interval) {
	var serviceFunc = {};
	
	// service functions
	serviceFunc.updateList = function() {
		var listLen = plus.storage.getLength();
		$rootScope.itemList = [];
		for(var i = 0; i < listLen; i ++) {
			var keyName = plus.storage.key(i);
			var valueObj = plus.storage.getItem(keyName);
			var value = JSON.parse(valueObj);
			$rootScope.itemList.push(value);
		}
	};
	
	// service initialization
	var stop = $interval(function() {
		if(window.plus){
			serviceFunc.updateList();
			$interval.cancel(stop);
		}
	}, 100);
	
	return serviceFunc;
}]);

/**
 * list controller
 */
myDrawerApp.controller('listCtrl',['$scope', '$rootScope', '$timeout', '$state', 'drawerService',function($scope, $rootScope, $timeout, $state, drawerService) {
	$scope.goToNewItemPage = function () {
		$state.go('newItem');
	};
	$scope.deleteItem = function(index) {
//		plus.io.resolveLocalFileSystemURL($rootScope.itemList[index].picPath, function ( entry ) {
//			entry.remove();
//		});
		plus.storage.removeItem($rootScope.itemList[index].date);
		$rootScope.itemList.splice(index, 1);
	};
	$scope.previewImage = function(picPath) {
		var url = "./templates/camera_image.html";
		var w = plus.webview.create(url,url,{hardwareAccelerated:true,scrollIndicator:'none',scalable:true,bounce:"all"});
		w.addEventListener( "loaded", function(){
			w.evalJS( "loadMedia('"+picPath+"')" );		
		}, false );
		w.addEventListener( "close", function() {
			w = null;
		}, false );
		w.show( "pop-in" );
	};
}]);

/**
 * new item controller
 */
myDrawerApp.controller('newItemCtrl', ['$scope', '$rootScope', '$state', 'drawerService', function($scope, $rootScope, $state, drawerService) {
	$scope.newItem = {
		"description": "",
		"picPath": ""
	};
	$scope.goTolistPage = function () {
		$state.go('list');
	};
	$scope.getPicPath = function() {
		if ($scope.newItem.picPath === "") {
			return "./img/plus.png";			
		}		
		return $scope.newItem.picPath;		
	};
	$scope.galleryImg = function (){
		// 从相册中选择图片
    	plus.gallery.pick( function(path){
    		var dateObj = new Date();
			$scope.newItem.date = dateObj.getFullYear() + '-'
							  	+ (dateObj.getMonth() + 1) + '-'
							  	+ dateObj.getDate() + ' '
							  	+ dateObj.getHours() + ':'
							  	+ dateObj.getMinutes() + ':'
							  	+ dateObj.getSeconds();
			$scope.newItem.picPath = path;
			$scope.$apply();
    	}, {filter:"image"} );
    	}, function ( e ) {    		
	};
	// take a photo
	$scope.getImage = function() {
		var cmr = plus.camera.getCamera();
		cmr.captureImage( function ( path ) {
			plus.gallery.save( path );
			var dateObj = new Date();
			$scope.newItem.date = dateObj.getFullYear() + '-'
							  	+ (dateObj.getMonth() + 1) + '-'
							  	+ dateObj.getDate() + ' '
							  	+ dateObj.getHours() + ':'
							  	+ dateObj.getMinutes() + ':'
							  	+ dateObj.getSeconds();
			$scope.newItem.picPath = path;
			$scope.$apply();
		}, function ( e ) {
		}, {filename:"_doc/gallery/",index:1} );
	};
	$scope.save = function() {
		if ($scope.newItem.picPath != "") {
			var keyName = $scope.newItem.date;
			var value = JSON.stringify($scope.newItem);
			plus.storage.setItem(keyName, value);
			$rootScope.itemList.push($scope.newItem);
			$scope.goTolistPage();
		}
	};
	$scope.cancel = function() {
//		if ($scope.newItem.picPath != "") {
//			plus.io.resolveLocalFileSystemURL($scope.newItem.picPath, function ( entry ) {
//				entry.remove();
//			});
//		}
		$scope.goTolistPage();
	};
}]);

/**
 * app route state
 */
myDrawerApp.config(function($stateProvider, $urlRouterProvider) {
	// For any unmatched url, redirect to /state1
  	$urlRouterProvider.otherwise('/list');
  	// Now set up the states
  	$stateProvider.state('list', {
      	url: '/list',
      	templateUrl: './templates/list.html',
      	controller: 'listCtrl'
    }).state('newItem', {
    	url: '/newItem',
    	templateUrl: './templates/newItem.html',
    	controller: 'newItemCtrl'
    });
});
