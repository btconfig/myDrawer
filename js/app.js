var myDrawerApp = angular.module('myDrawerApp', ['ui.router']);

/**
 * app service
 */
myDrawerApp.service('drawerService', ['$rootScope', '$interval', function($rootScope,$interval) {
	var serviceFunc = {};
	
	// service functions
	serviceFunc.updateList = function() {
		var listLen = plus.storage.getLength();
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
			$rootScope.itemList = [];
			serviceFunc.updateList();
			$interval.cancel(stop);
		}
	}, 100);
	
	return serviceFunc;
}]);

/**
 * main controller
 */
myDrawerApp.controller('mainCtrl', ['$scope', '$state', 'drawerService', function($scope,$state,drawerService) {
	$scope.ifNewItemState = false;
	$scope.addNewItem = function () {
		$state.go('newItem');
		$scope.ifNewItemState = true;
	};
	$scope.goTolistPage = function () {
		$state.go('list');
		$scope.ifNewItemState = false;
	};
}]);

/**
 * list controller
 */
myDrawerApp.controller('listCtrl',['$scope', 'drawerService',function($scope,drawerService) {
}]);

/**
 * new item controller
 */
myDrawerApp.controller('newItemCtrl', ['$scope', 'drawerService', function($scope, drawerService) {
	$scope.newItem = {
		"description": ""
	};
	// take a photo
	$scope.getImage = function() {
		var cmr = plus.camera.getCamera();
		cmr.captureImage( function ( p ) {
			plus.io.resolveLocalFileSystemURL( p, function ( entry ) {
				var dateObj = new Date();
				$scope.newItem.date = dateObj.getFullYear() + '-'
									  	+ (dateObj.getMonth() + 1) + '-'
									  	+ dateObj.getDate() + ' '
									  	+ dateObj.getHours() + ':'
									  	+ dateObj.getMinutes() + ':'
									  	+ dateObj.getSeconds();
				$scope.newItem.picPath = entry.toLocalURL();
				var keyName = $scope.newItem.date;
				var value = JSON.stringify($scope.newItem);
				plus.storage.setItem(keyName, value);
				drawerService.updateList();
			}, function ( e ) {
				console.log( "读取拍照文件错误："+e.message );
			} );
		}, function ( e ) {
			console.log( "失败："+e.message );
		}, {filename:"_doc/camera/",index:1} );
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
