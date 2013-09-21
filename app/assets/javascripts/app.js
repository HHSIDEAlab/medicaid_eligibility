'use strict';

angular.module('MAGI',['ui.mask','ngRoute','ngAnimate','MAGI.filters','MAGI.services',
					   'MAGI.directives','MAGI.controllers']).
	config(['$routeProvider', function($routeProvider){
		$routeProvider.
			when('/application', {templateUrl: '/assets/form.html', 
								  controller: 'FormController'}).
			when('/results', {templateUrl: '/assets/results.html',
							  controller:  'ResultsController'}).
			otherwise({redirectTo: '/application'});
	}])