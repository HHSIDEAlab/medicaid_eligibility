'use strict';

angular.module('MAGI',['btford.dragon-drop','ui.mask','MAGI.filters','MAGI.services',
					   'MAGI.directives','MAGI.controllers']).
	config(['$routeProvider', function($routeProvider){
		$routeProvider.when('/application', {templateUrl: '/assets/form.html', controller: 'FormController'});
		$routeProvider.when('/results', {templateUrl: '/assets/results.html', controller:  'ResultsController'});
		$routeProvider.when('/exportimport', {templateUrl: '/assets/exportimport.html', controller: 'ExportImportController'});
		$routeProvider.otherwise({redirectTo: '/application'});
	}]);