'use strict';

angular.module('MAGI.controllers', ['ngCookies']).
  controller('FormController',['$scope','$location','$anchorScroll','$timeout','$log','$filter','$cookies', '$cookieStore',
    'filterFilter', 'Application','relationshipCodes','states','applicationYears','applicationStatuses', 
    function($scope, $location, $anchorScroll, $timeout, $log, $filter, $cookies, $cookieStore, filterFilter, Application, relationshipCodes, states, applicationYears, applicationStatuses){
        var acceptedNoticeSession = false;
        
        $scope.disableSubmit = function() {
          return gon.restrictStates && $scope.application.state && !(_.contains(gon.enabledStates, $scope.application.state.abbr));
        }

        Application.resetResults();
        $scope.submitted = false;
        $scope.applicants = Application.applicants;
        $scope.taxReturns = Application.taxReturns;
        $scope.application = Application;

        $scope.addTaxReturn = Application.addTaxReturn;
        
        $scope.removeApplicant = function(app){
          $scope.application.removeApplicant(app);
        };

        $scope.removeTaxReturn = Application.removeTaxReturn;
        $scope.relationshipCodes = relationshipCodes;

        $scope.newHousehold = [];

        $scope.exportApplication = function(){
          if((navigator.userAgent.indexOf("MSIE") != -1 ) || (!!document.documentMode == true )) {
            $location.path("/exportraw");
          } else {
            applicationJson = angular.toJson(Application.serialize(), true);

            var a = window.document.createElement('a');
            a.href = window.URL.createObjectURL(new Blob([applicationJson], {type: 'application/json'}));
            a.download = 'mitcexport_' + $filter('date')(new Date(), "yyyyMMdd") + '.json';

            // Append anchor to body.
            document.body.appendChild(a)
            a.click();

            // Remove anchor from body
            document.body.removeChild(a)
          }
        };

        $scope.$watch('newHousehold.length', function(newVal,oldVal){
          if(newVal > 0){
            $scope.application.households.push([$scope.newHousehold.pop()]); 
          }
        });

        $scope.rehouseholdingHappened = function(){
          return _.chain($scope.application.households).
            map(function(hh){return hh.length;}).
            reduce(function (m, w) {return m + w;}, 0).
            value() == $scope.applicants.length;

        };

        $scope.$watch('rehouseholdingHappened()', function(newVal, oldVal){
          if(newVal){
            $scope.application.cleanHouseholds();
          }
        });

        $scope.showNewHousehold = function(){
          return $scope.application.households.length < $scope.applicants.length;
        };

        $scope.showHouseholds = function(){
          return $scope.applicants.length > 1;
        };

        $scope.checkEligibility = function(){
          $log.info("Form Valid: " + $scope.applicationForm.$valid);
          $log.info(JSON.stringify($scope.application.serialize()));
          var invalid_elements = angular.element(document.querySelector("input.ng-invalid"));
          if($scope.applicationForm.$valid || invalid_elements.length == 0){
            var serv = $scope.application.checkEligibility();
            serv.then(function(resp){
                $location.path("/results");
            }, function(err){
             $scope.errorMessage = angular.fromJson(err)["data"]["Error"];             
            });
          } else {
            $scope.submitted = true;
            $timeout(
                function(){
                  invalid_elements[0].focus( );
            });              
          }
        };


        $scope.addApplicant = function(){
            Application.addApplicant("Applicant " + ($scope.applicants.length+1));
        };

        $scope.showFilers = function(){
            return $scope.applicants.length > 0;
        };


        // We want to initialize the application with an applicant and a tax return
        if($scope.applicants.length === 0){
            $scope.addApplicant();
            $scope.addTaxReturn();
        }


        $scope.states = states;
        $scope.appStates = _.filter(states, function(state){return state.inApp;});
        $scope.appYears = applicationYears;
        $scope.appStatuses = applicationStatuses;
        $scope.qualNonCitizenStatuses = _.filter(applicationStatuses, function(status){return status.qnc;});

  }]).
    controller('ApplicantController',['$scope',function($scope){
        $scope.checkResponsibility = function(){
            return $scope.applicant.age !== null && $scope.applicant.age <= 19;
        };

        $scope.$watch('checkResponsibility()', function(newValue,oldValue){
         if (!newValue) {
          $scope.applicant.nonParentResponsibility = false;
          $scope.application.clearResponsibility($scope.applicant);
         }
        });

        $scope.showAgeField = function() {
          return !($scope.applicant.age >= 90 || $scope.applicant.age90OrOlder);
        };

        $scope.showAgeCheckbox = function() {
          return $scope.applicant.age90OrOlder;
        };

        $scope.updateAge = function(applicant) {
          if (applicant.age >= 90) {
            $scope.applicant.age90OrOlder = true;
            $scope.applicant.age = null;
          }
        }

        $scope.$watch('applicant.pregnantThreeMonths', function(newValue,oldValue){
            if(newValue){
                $scope.applicant.pregnant = false;
            }
        });

        $scope.$watch('applicant.pregnant', function(newValue,oldValue){
            if(newValue){
                $scope.applicant.pregnantThreeMonths = false;
            }
        });

        $scope.updateRelationship = function(relationship){
            relationship.updateOpposite();
        };

        $scope.clearResponsibility = function(dependent){
         $scope.application.clearResponsibility(dependent);
        };

        $scope.updateResponsibility = function(dependent){
         $scope.application.clearResponsibility(dependent);
         if (dependent.nonParentResponsibility && dependent.nonParentResponsibilityPerson) {
          dependent.nonParentResponsibilityPerson.addResponsibility(dependent);
         }
        };

        $scope.updateMonthly = function(applicant){
         applicant.updateMonthly();
        };

        $scope.updateWages = function(applicant){
         applicant.updateWages();
        };

        $scope.notMe = function(other) {
            return other !== $scope.applicant; 
        };
    }]).
    controller('ResultsController',['$scope','$location','$filter','Application', function($scope,$location,$filter,Application){
        $scope.application = Application;
        $scope.applicants = Application.determination['Applicants'];
        $scope.expandByDefault = function(){
            // return $scope.applicants.length == 1;
            return true;
        };

        $scope.exportApplication = function(){
          if((navigator.userAgent.indexOf("MSIE") != -1 ) || (!!document.documentMode == true )) {
            $location.path("/exportraw");
          } else {
            applicationJson = angular.toJson(Application.serialize(), true) + "\n\n" + angular.toJson(Application.determination, true);

            var a = window.document.createElement('a');
            a.href = window.URL.createObjectURL(new Blob([applicationJson], {type: 'application/json'}));
            a.download = 'mitcexport_' + $filter('date')(new Date(), "yyyyMMdd") + '.json';

            // Append anchor to body.
            document.body.appendChild(a)
            a.click();

            // Remove anchor from body
            document.body.removeChild(a)
          }
        };


        $scope.returnToForm = function(){
            $location.path("/application");
        };

        $scope.yDetermination = function(other) {
            return other.indicator == 'Y' && !(other.hide);
        };
    }]).
    controller('ExportImportController',['$scope','$location','$log','Application', function($scope,$location,$log,Application){
        $scope.applicationJson = angular.toJson(Application.serialize(), true);
        $scope.resultsJson = angular.toJson(Application.determination, true);

        $scope.showResults = _.keys(Application.determination).length > 0;

        $scope.importApplication = function(){
            // Note - may want to wrap this in a try/catch loop of some sort
            var application = angular.fromJson($scope.applicationJson);
            $log.info(application);
            Application.deserialize(application);
            // Redirect to application
            $location.path("/application");
        };

        $scope.returnToForm = function(){
            $location.path("/application");
        };
    }]).
    controller('ExportRawController',['$scope','$location','$log','Application', function($scope,$location,$log,Application){
        $scope.applicationJson = angular.toJson(Application.serialize(), true);
        $scope.resultsJson = angular.toJson(Application.determination, true);

        $scope.showResults = _.keys(Application.determination).length > 0;

        $scope.returnToForm = function(){
            $location.path("/application");
        };
    }]).
    controller('TaxReturnController', ['$scope','$log',function($scope,$log){
      $scope.inputs = {newFiler: {}, newDependent: {}};

      $scope.canAddFiler = function(){
        return $scope.taxReturn.canAddFiler($scope.application);
      };

      $scope.showDependents = function(){
        return $scope.taxReturn.dependents.length > 0 || $scope.canAddDependent();
      };

      $scope.canAddDependent = function(){
        return $scope.taxReturn.canAddDependent($scope.application);
      }

      $scope.$watch('inputs.newFiler', function(newFiler, oldVal){
        $log.info(newFiler);
        if(newFiler.uid){
          $scope.taxReturn.addFiler(newFiler);
          $scope.inputs.newFiler = {};
        }
      });

      $scope.removeFiler = function(filer){
       return $scope.taxReturn.removeFiler(filer);
      };

      $scope.$watch('inputs.newDependent', function(newDependent, oldVal){
        if(newDependent.uid){
          $scope.taxReturn.addDependent(newDependent);
          $scope.inputs.newDependent = {};
        }
      });

      $scope.removeDependent = function(dependent){
       return $scope.taxReturn.removeDependent(dependent);
      };


    }]);
