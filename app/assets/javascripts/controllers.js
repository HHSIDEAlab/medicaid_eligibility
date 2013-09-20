'use strict';

angular.module('MAGI.controllers', []).
	controller('FormController',['$scope','filterFilter', 'Application','relationshipCodes','states', function($scope,filterFilter, Application, relationshipCodes,states){		
                $scope.applicants = Application.applicants;
                $scope.taxReturns = Application.taxReturns;
                $scope.state = Application.state;

                $scope.addTaxReturn = Application.addTaxReturn;
                $scope.removeApplicant = Application.removeApplicant;
                $scope.removeTaxReturn = Application.removeTaxReturn;
                $scope.relationshipCodes = relationshipCodes;


                $scope.addApplicant = function(){
                        Application.addApplicant("Applicant " + ($scope.applicants.length+1));
                };

                $scope.showFilers = function(){
                        return $scope.applicants.length > 0;
                }

                $scope.showDependents = function(){
                        return $scope.applicants.length > 1;
                }


                // We want to initialize the application with an applicant and a tax return
                $scope.addApplicant();
                $scope.addTaxReturn();


		$scope.states = states;
	}]).
        controller('ApplicantController',['$scope',function($scope){
                $scope.checkResponsibility = function(){
                        return $scope.applicant.age <= 19
                };

                $scope.$watch('checkResponsibility()', function(newValue,oldValue){
                        $scope.applicant.nonParentResponsibility = false;
                });

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
                }

                $scope.notMe = function(other) {
                        return other !== $scope.applicant; 
                } 
        }]);
