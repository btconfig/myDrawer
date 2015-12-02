var myDrawerApp = angular.module('myDrawerApp', ['ui.router']);

myDrawerApp.controller('mainCtrl', ['$scope', '$state', function($scope,$state) {
	$scope.ifNewItemState = false;
	$scope.addNewItem = function () {
		$state.go('newItem');
		$scope.ifNewItemState = true;
	}
	$scope.listItem = function () {
		$state.go('list');
		$scope.ifNewItemState = false;
	}
}]);

myDrawerApp.controller('listCtrl',['$scope' ,function($scope) {
	$scope.picList = [];
	$scope.hello = function () {
		alert('hello');
	};
	// 拍照
	$scope.getImage = function() {
		var cmr = plus.camera.getCamera();
		cmr.captureImage( function ( p ) {
			plus.io.resolveLocalFileSystemURL( p, function ( entry ) {
				$scope.picList.push(entry.toLocalURL());
			}, function ( e ) {
				console.log( "读取拍照文件错误："+e.message );
			} );
		}, function ( e ) {
			console.log( "失败："+e.message );
		}, {filename:"_doc/camera/",index:1} );
	};
}]);

myDrawerApp.controller('newItemCtrl', ['$scope', function($scope) {
	$scope.newItem = {
		"description": "hello"
	};
}]);

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
