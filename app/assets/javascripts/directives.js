angular.module('MAGI.directives',[]).
    directive('checker', function($timeout){
        return {
            template: '<button type="button" class="checker"><span></span></button>',
            replace: true,
            require:"?ngModel",
            priority: 10,
            link: function(scope, element, attr, ngModel){
                if(!ngModel) return;

                attr.$set('type', 'button');
                var elm = element;
                ngModel.$render = function(){
                    if(ngModel.$viewValue){
                        elm.addClass("checked");
                    } else {
                        elm.removeClass("checked");
                    };
                };

                elm.bind('click', function(){
                    scope.$apply(function(){
                        ngModel.$setViewValue(!elm.hasClass("checked"));
                        ngModel.$render();
                    });
                    $timeout(function(){
                        elm[0].focus();
                    });
                });
            }
        }
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
          var annualVal = ngModelCtrl.$viewValue;

          // Set annual to the rounded, calculated value if necessary
          // (This prevents turning "12.0" into "12")
          if ((annual.val() != annualVal) || annual.val().search(/^\-?[0-9]+\.[0-9]{5,}$/) != -1) {
            annual.val(annualVal);
          }

          if (annual.val() == '') {
            monthly.val('');
          } else {
            monthlyVal = Math.round(annualVal / 12.0 * 100.0) / 100.0;
            if (monthly.val() != monthlyVal || monthly.val().search(/^\-?[0-9]+\.[0-9]{5,}$/) != -1) {
              monthly.val(monthlyVal);
            }
          }
        };

        monthly.bind('input change', function(evt){
          scope.$apply(updateViaMonthly);
        });

        annual.bind('input change', function(){
          scope.$apply(updateViaAnnual);
        });

        function updateViaMonthly(){
          // Check that this is a valid amount
          if (monthly.val().search(/^\-?[0-9]+(\.[0-9]+)?$/) != -1) {
            // Throw out everything after two decimals
            var monthlyVal = Math.floor(monthly.val() * 100.0) / 100.0;
            // Set annual amount to 12 times the monthly amount, rounded to two decimals
            ngModelCtrl.$setViewValue(Math.round(monthlyVal * 12.0 * 100.0) / 100.0);
            ngModelCtrl.$render();
          }
        }

        function updateViaAnnual(){
          // Check that this is a valid amount
          if (annual.val().search(/^\-?[0-9]+(\.[0-9]+)?$/) != -1) {
            // Throw out everything after two decimals
            var annualVal = Math.floor(annual.val() * 100.0) / 100.0;
            ngModelCtrl.$setViewValue(annualVal);
            ngModelCtrl.$render();
          }
        }
      }
    }
  }).
  directive('numberinput', function(){
    return {
      restrict: 'EA',
      require: 'ngModel',
      template: '',
      replace: true,
      link: function(scope, element, attrs, ngModelCtrl){
        var numberInput = angular.element(element[0]);

        numberInput.bind('input change', function(evt){
          scope.$apply(trimZeroes);
        });

        function trimZeroes(){
          if (numberInput.val() == '') {
            ngModelCtrl.$setViewValue(0);
            ngModelCtrl.$render();
          } else if (numberInput.val() != parseInt(numberInput.val()).toString()) {
            ngModelCtrl.$setViewValue(999);
            ngModelCtrl.$setViewValue(parseInt(numberInput.val()).toString());
            ngModelCtrl.$render();
          }
        }
      }
    }
  });
