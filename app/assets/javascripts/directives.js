angular.module('MAGI.directives',[]).
	directive('checker', function($timeout){
		// Runs during compile
		return {
			restrict: 'A',
			scope: {
				ngModel: '=',
				id: '@'
			}, 
			template: '<div class="checker" ng-class="{focus:focus}"><span ng-class="{checked:ngModel}" ng-click="toggle()" >{{text}}</span><input type="checkbox" id="{{id}}" name="{{id}}" ng-model="ngModel" ng-change=setFocus() ng-focus=gotFocus() ng-blur=lostFocus()></div>',
			replace: true,
			link: function(scope, element, attrs) {
				attrs.$observe('id', function(value) {				    
					element.attr('id','uniform-'+value);
				});

				scope.toggle = function(){
					scope.ngModel = !scope.ngModel;
					scope.setFocus();
					return false;
				}

				scope.setFocus = function(){
					$timeout(function(){element[0].children[1].focus();});
				}

				scope.gotFocus = function(){
					scope.focus = true;
				}

				scope.lostFocus = function(){
					scope.focus = false;
				}

			}
		};
	}).
	directive('selector', function($interpolate,$timeout){
		return {
			restrict: 'A',
			priority: 100,
			template: '<div class="selector fixedWidth"><span style="-webkit-user-select: none;">{{text}}</span><div ng-transclude></div>',
			replace: true,
			transclude: 'element',
			link: function(scope, element, attrs) {
				
				attrs.$observe('id', function(value) {				    
					element.attr('id','uniform-'+value);
				});

				var selector = angular.element(element.find("select"))[0];
				var spn = element.find("span")[0];

				var setFocus = function(){
					element.addClass('focus');
				}

				var removeFocus = function(){
					element.removeClass('focus');
				}

				// Note. This is ugly. It's here to handle updating the text box, but there really should be something cleaner.
				scope.$watch(
					function(){
						$timeout(function(){
							angular.element(spn).text(angular.element(_.find(angular.element(selector).find('option'),function(opt){
								return opt.value==selector.value;
							})).text());
						},0,false);
				});

				angular.element(element.find("select")[0]).bind('focus',setFocus);
				angular.element(element.find("select")[0]).bind('blur',removeFocus);

			}
		};
	}).
	directive('eligibility', function(){
		return {		
			template: "<span class='eligibility' ng-class='{ineligible:(value == \"N\"), eligible:(value==\"Y\")}'><i ng-class='{\"icon-remove\":(\"{{value}}\" == \"N\"), \"icon-ok\":(\"{{value}}\"==\"Y\")}'></i><span ng-if='value==\"N\"'>Not </span>Medicaid Eligible</span>",
			restrict: 'E',
			scope: {
				value: '@value'
			},
			replace: true
		}
	});
