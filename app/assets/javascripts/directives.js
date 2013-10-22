angular.module('MAGI.directives',[]).
	directive('checker', function($timeout){
		// Runs during compile
		return {
			restrict: 'A',
			scope: {
				ngModel: '=',
				id: '@'
			}, 
			template: '<div class="checker"><span ng-class="{checked:ngModel}" ng-click="toggle()" ><input type="checkbox" id="{{id}}" name="{{id}}" ng-model="ngModel" ng-change="setFocus()" ng-focus="gotFocus()" ng-blur="lostFocus()" /></span></div>',
			replace: true,
			link: function(scope, element, attrs) {
				attrs.$observe('id', function(value) {				    
					element.attr('id','uniform-'+value);
				});

				scope.toggle = function(){
					scope.setFocus();
					return false;
				}

				scope.setFocus = function(){
					$timeout(function(){element[0].children[0].children[0].focus();});
				}

				var setFocus = function(){
					element.addClass('focus');
				}

				var removeFocus = function(){
					element.removeClass('focus');
				}


				angular.element(element[0].children[0].children[0]).bind('focus',setFocus);
				angular.element(element[0].children[0].children[0]).bind('blur',removeFocus);


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
        template: "<span class='eligibility' ng-class='{ineligible:(value == \"N\"), eligible:(value==\"Y\")}'><i ng-class='{\"icon-remove\":(\"{{value}}\" == \"N\"), \"icon-ok\":(\"{{value}}\"==\"Y\")}'></i><span ng-show='value==\"N\"'>Not </span>{{program}} Eligible</span>",
        restrict: 'A',
        scope: {
            value: '@value',
            program: '@program'
        },
        replace: true
    }
  }).
  directive('incomegroup', function(){
  	return {
  		restrict: 'EA',
  		require: 'ngModel',
  		template: '<div><div class="form-half-field clear"><label>Monthly</label><input type="number" class="long-number monthly"></div><div class="form-half-field"><label>Annual</label><input type="number" class="long-number annual"></div></div>',
  		replace: true,
  		link: function(scope, element, attrs, ngModelCtrl){


  			var monthlyLabel = angular.element(element[0].children[0].children[0]);
  			var annualLabel = angular.element(element[0].children[1].children[0]);
  			var monthly = angular.element(element[0].children[0].children[1]);
  			var annual = angular.element(element[0].children[1].children[1]);

  			monthlyLabel.text(attrs['monthlylabel']);
  			annualLabel.text(attrs['annuallabel']);

  			ngModelCtrl.$render = function() {
  				annual.val(ngModelCtrl.$viewValue || 0);
  				monthly.val(Math.floor(ngModelCtrl.$viewValue / 12) || 0);
            };

  			monthly.bind('input change', function(evt){
  				scope.$apply(updateViaMonthly);
  			});

  			annual.bind('input change', function(){
  				scope.$apply(updateViaAnnual);
  			});

  			function updateViaMonthly(){
  				ngModelCtrl.$setViewValue(monthly.val() * 12);
  				ngModelCtrl.$render();
  			}

  			function updateViaAnnual(){
  				ngModelCtrl.$setViewValue(annual.val() * 1);
  				ngModelCtrl.$render();
  			}
  		}
  	}
  });
