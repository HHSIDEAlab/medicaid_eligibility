'use strict';

angular.module('MAGI.controllers', []).
	controller('FormController',['$scope','filterFilter', function($scope,filterFilter){		
		$scope.application = {
			applicants: [],
			taxReturns: []
		};

                $scope.$watch('application.applicants.length', function (newValue, oldValue){
                        $scope.numFilers = Math.min(newValue,2);
                        $scope.numDependents = Math.max(newValue-1,0);

                        angular.forEach($scope.application.taxReturns, function(taxReturn){
                                $scope.checkNumFilers(taxReturn);
                        });

                },true);

		$scope.states = [
			{abbr: 'AL', name: 'Alabama'},
                        {abbr: 'AK', name: 'Alaska'},
                        {abbr: 'AZ', name: 'Arizona'},
                        {abbr: 'AR', name: 'Arkansas'},
                        {abbr: 'CA', name: 'California'},
                        {abbr: 'CO', name: 'Colorado'},
                        {abbr: 'CT', name: 'Connecticut'},
                        {abbr: 'DE', name: 'Delaware'},
                        {abbr: 'DC', name: 'District Of Columbia'},
                        {abbr: 'FL', name: 'Florida'},
                        {abbr: 'GA', name: 'Georgia'},
                        {abbr: 'HI', name: 'Hawaii'},
                        {abbr: 'ID', name: 'Idaho'},
                        {abbr: 'IL', name: 'Illinois'},
                        {abbr: 'IN', name: 'Indiana'},
                        {abbr: 'IA', name: 'Iowa'},
                        {abbr: 'KS', name: 'Kansas'},
                        {abbr: 'KY', name: 'Kentucky'},
                        {abbr: 'LA', name: 'Louisiana'},
                        {abbr: 'ME', name: 'Maine'},
                        {abbr: 'MD', name: 'Maryland'},
                        {abbr: 'MA', name: 'Massachusetts'},
                        {abbr: 'MI', name: 'Michigan'},
                        {abbr: 'MN', name: 'Minnesota'},
                        {abbr: 'MS', name: 'Mississippi'},
                        {abbr: 'MO', name: 'Missouri'},
                        {abbr: 'MT', name: 'Montana'},
                        {abbr: 'NE', name: 'Nebraska'},
                        {abbr: 'NV', name: 'Nevada'},
                        {abbr: 'NH', name: 'New Hampshire'},
                        {abbr: 'NJ', name: 'New Jersey'},
                        {abbr: 'NM', name: 'New Mexico'},
                        {abbr: 'NY', name: 'New York'},
                        {abbr: 'NC', name: 'North Carolina'},
                        {abbr: 'ND', name: 'North Dakota'},
                        {abbr: 'OH', name: 'Ohio'},
                        {abbr: 'OK', name: 'Oklahoma'},
                        {abbr: 'OR', name: 'Oregon'},
                        {abbr: 'PA', name: 'Pennsylvania'},
                        {abbr: 'RI', name: 'Rhode Island'},
                        {abbr: 'SC', name: 'South Carolina'},
                        {abbr: 'SD', name: 'South Dakota'},
                        {abbr: 'TN', name: 'Tennessee'},
                        {abbr: 'TX', name: 'Texas'},
                        {abbr: 'UT', name: 'Utah'},
                        {abbr: 'VT', name: 'Vermont'},
                        {abbr: 'VA', name: 'Virginia'},
                        {abbr: 'WA', name: 'Washington'},
                        {abbr: 'WV', name: 'West Virginia'},
                        {abbr: 'WI', name: 'Wisconsin'},
                        {abbr: 'WY', name: 'Wyoming'},
		];

                $scope.relationshipCodes = [
                        {code: '02', label: 'Spouse', opposite: '02'},
                        {code: '03', label: 'Parent', opposite: '04'},
                        {code: '04', label: 'Child', opposite: '03'},
                        {code: '05', label: 'Stepchild', opposite: '12'},
                        {code: '06', label: 'Grandchild', opposite: '15'},
                        {code: '07', label: 'Sibling', opposite: '07'},
                        {code: '08', label: 'Domestic partner', opposite: '08'},
                        {code: '12', label: 'Stepparent', opposite: '05'},
                        {code: '13', label: 'Uncle/Aunt', opposite: '14'},
                        {code: '14', label: 'Nephew/Niece', opposite: '13'},
                        {code: '15', label: 'Grandparent', opposite: '06'},
                        {code: '16', label: 'Cousin', opposite: '16'},
                        {code: '17', label: "Parent's domestic partner", opposite: 'XX'},
                        {code: '23', label: 'Sibling-in-law', opposite: '23'},
                        {code: '26', label: 'Child-in-law', opposite: '30'},
                        {code: '27', label: 'Former spouse', opposite: '27'},
                        {code: '30', label: 'Parent-in-law', opposite: '26'},
                        {code: 'XX', label: "Domestic partner's child", opposite: '17'},
                        {code: '88', label: "Other", opposite: '88'}
                ]


		$scope.addApplicant = function(){
                        var newApplicant = {
                                id: "Applicant " + ($scope.application.applicants.length+1),
                                citizen: true,
                                stateResidency: true,
                                isApplicant: true,
                                relationships: _.map($scope.application.applicants, function(applicant){
                                        return {otherApplicant: applicant};
                                })
                        }

			angular.forEach($scope.application.applicants,function(applicant){
                                applicant.relationships.push({otherApplicant: newApplicant});
                        });

                        $scope.application.applicants.push(newApplicant);
                        
		}

		$scope.addTaxReturn = function(){
                        var taxReturn = {
                                filers:[],
                                dependents: []
                        };
                        $scope.checkNumFilers(taxReturn);
			$scope.application.taxReturns.push(taxReturn);
		}

                $scope.checkNumFilers = function(taxReturn){
                        while(taxReturn.filers.length < $scope.numFilers){
                                taxReturn.filers.push({});
                        }
                        while(taxReturn.filers.length > $scope.numFilers){
                                taxReturn.filers.pop();
                        }
                        while(taxReturn.dependents.length < $scope.numDependents){
                                taxReturn.dependents.push({});
                        }
                        while(taxReturn.dependents.length > $scope.numDependents){
                                taxReturn.dependents.pop();
                        }
                }

                $scope.removeApplicant = function(applicant){
                        var removeIndex = $scope.application.applicants.indexOf(applicant);
                        $scope.application.applicants.splice(removeIndex,1);
                        angular.forEach($scope.application.applicants,function(otherApplicant){
                                var otherRel = _.find(otherApplicant.relationships, function(rel){
                                        return rel.otherApplicant == applicant;
                                });
                                var otherRelIndex = otherApplicant.relationships.indexOf(otherRel);
                                otherApplicant.relationships.splice(otherRelIndex, 1);
                        });

                        if($scope.application.applicants.length == 0){
                                $scope.addApplicant();
                        }
                }

                $scope.removeTaxReturn = function(taxReturn){
                        $scope.application.taxReturns.splice($scope.application.taxReturns.indexOf(taxReturn),1);
                        if($scope.application.taxReturns.length == 0){
                                $scope.addTaxReturn();
                        }
                }


		$scope.doStuff = function(){
			$scope.application.applicants[0].pregnant = true;
		}

                $scope.addApplicant();
                $scope.addTaxReturn();
	}]).
        controller('ApplicantController',['$scope',function($scope){
                $scope.checkResponsibility = function(){
                        return $scope.applicant.age <= 19
                };

                $scope.$watch('checkResponsibility()', function(newValue,oldValue){
                        $scope.applicant.nonParentResponsibility = false;
                });

                $scope.updateRelationship = function(relationship){
                        var otherRel = _.find(relationship.otherApplicant.relationships,function(rel){
                                return rel.otherApplicant==$scope.applicant;
                        });

                        var myCode = _.find($scope.relationshipCodes, function(rc){
                                return rc.code == relationship.code;
                        });

                        otherRel.code = myCode.opposite;
                }

                $scope.notMe = function(other) {
                        return other !== $scope.applicant; 
                } 
        }]);
