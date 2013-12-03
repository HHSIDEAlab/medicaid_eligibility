angular.module('MAGI.services',[]).
    factory('Application', ['$http','$log','relationshipCodes','states', '$location', function($http,$log,relationshipCodes, states, $location){
		function Application(){
			this.applicationId = "";
			this.applicants = [];
			this.taxReturns = [];
			// get the state from the URL if it is set
			this.state = _.find(states, function(st){
				return st.abbr == ($location.search()).state;
			});
			this.determination = {};
			this.households = [[]];
		}

		function TaxReturn(){
			this.filers = [];
			this.dependents = [];
		}

		function Applicant(){
		    this.hours = 0;
			this.citizen = true;
			this.livesInState = true;
			this.isApplicant = true;
			this.numberOfChildrenExpected = 1;
			this.incomeTaxes = new IncomeTaxes();
			this.relationships = [];
			this.nonCitizen = {};
			this.fosterCare = {
				state: {}
		    };
		}

		function Relationship(applicant, otherApplicant, code){
			this.applicant = applicant;
			this.otherApplicant = otherApplicant;
			this.code = code;
		}

		function IncomeTaxes(){
			var me = this;
			angular.forEach(this.fields, function(field){
				me[field.app] = 0;
			});
		}

		IncomeTaxes.prototype.fields = [
        {app: 'monthly',            api:'Monthly Income'},
		    {app: 'wages',              api:'Wages, Salaries, Tips'},
		    {app: 'taxableInterest',    api: 'Taxable Interest'},
		    {app: 'taxExemptInterest',  api:'Tax-Exempt Interest'},
		    {app: 'taxableRefunds',     api: 'Taxable Refunds, Credits, or Offsets of State and Local Income Taxes'},
		    {app: 'alimony',            api: 'Alimony'},
		    {app: 'capitalGains',       api: 'Capital Gain'},
        {app: 'capitalLosses',      api: 'Capital Loss'},
		    {app: 'pensions',           api: 'Pensions and Annuities Taxable Amount'},
		    {app: 'farmIncome',         api: 'Farm Income'},
        {app: 'farmLoss',           api: 'Farm Loss'},
		    {app: 'unemployment',       api: 'Unemployment Compensation'},
		    {app: 'other',              api: 'Other Income'},
		    {app: 'MAGIDeductions',     api: 'MAGI Deductions'}
		];

		IncomeTaxes.prototype.serialize = function(){
			var me = this;
			var incomeData =  _.map(this.fields, function(field){
				var val = me[field.app] ? me[field.app] : 0;
				return [field.api, val];
			});
			return _.object(incomeData);
		};

		IncomeTaxes.prototype.deserialize = function(obj){
			var me = this;
			angular.forEach(this.fields, function(field){
				me[field.app] = obj[field.api];		
			});
			return this;
		};

		// Note. Remove this eventually. UI should not have to deal with service
		// For now, sets the number of filers and dependents in a tax return to 
		// be an appropriate amount for the number of applicants
		TaxReturn.prototype.checkNumFilers = function(numApplicants){
			// var numFilers = Math.min(numApplicants,2);
			// while(this.filers.length < numFilers){
   //                  this.filers.push({});
   //          }
   //          while(this.filers.length > numFilers){
   //                  this.filers.pop();
   //          }
            
   //          var numDependents = Math.max(numApplicants-1,0);
   //          while(this.dependents.length < numDependents){
   //                  this.dependents.push({});
   //          }
   //          while(this.dependents.length > numDependents){
   //                  this.dependents.pop();
   //          }
		};

		TaxReturn.prototype.canAddFiler = function(application){
			return (this.filers.length < 2 ) && (this.filers.length < application.applicants.length);
		};

		TaxReturn.prototype.canAddDependent = function(application){
			return (this.filers.length > 0) && (this.dependents.length < application.applicants.length - 1);
		};

		TaxReturn.prototype.addFiler = function(applicant){
			this.filers.push(applicant);
		};

		TaxReturn.prototype.addDependent = function(applicant){
			this.dependents.push(applicant);
		};


		Application.prototype.addTaxReturn = function(){
			var taxReturn = new TaxReturn();
			taxReturn.checkNumFilers(this.applicants.length);
			this.taxReturns.push(taxReturn);
		};

		Application.prototype.removeTaxReturn = function(taxReturn){
			this.taxReturns.splice(this.taxReturns.indexOf(taxReturn),1);
            if(this.taxReturns.length === 0){
            	this.addTaxReturn();
            }
		};

		Application.prototype.cleanHouseholds = function(){
			var idx = _.map(this.households, function(hh){return hh.length;}).indexOf(0);
			if(idx >= 0 && this.applicants.length > 0){
				this.households.splice(idx,1);
			}
		};

		Application.prototype.addApplicant = function(applicantName){
			var applicant = new Applicant();
			applicant.id = applicantName;

			angular.forEach(this.applicants, function(other){
				other.addRelationship(applicant);
				applicant.addRelationship(other);
			});

			this.applicants.push(applicant);
			this.households[0].push(applicant);
			var appl = this;

			angular.forEach(this.taxReturns, function(taxReturn){
				taxReturn.checkNumFilers(appl.applicants.length);
			});
		};

		Applicant.prototype.addRelationship = function(other){
			this.relationships.push(new Relationship(this, other, ''));
		};

		Applicant.prototype.getRelationship = function(otherApplicant){
			return _.find(this.relationships, function(rel){
				return rel.otherApplicant == otherApplicant;
			});
		};

		Applicant.prototype.removeRelationship = function(otherApplicant){
			var toRemove = this.getRelationship(otherApplicant);
			var idx = this.relationships.indexOf(toRemove);
            this.relationships.splice(idx, 1);
		};

		Applicant.prototype.removeRelationships = function(){
			angular.forEach(this.relationships, function(rel){
				rel.otherApplicant.removeRelationship(this);
			});
		};

		Application.prototype.removeApplicant = function(applicant){
			var me = this;

            angular.forEach(me.households, function(hh, idx){
            	var hhri = hh.indexOf(applicant);
            	if(hhri >= 0){
            		me.households[idx].splice(hhri,1);
	            }
            });

            angular.forEach(me.taxReturns, function(tr, idx){
            	var trfri = tr.filers.indexOf(applicant);
            	if(trfri >= 0){
            		tr.filers.splice(trfri, 1);
            	}

            	var trdri = tr.dependents.indexOf(applicant);
            	if(trdri >= 0){
            		tr.dependents.splice(trdri, 1);
            	}
            });

			var removeIndex = this.applicants.indexOf(applicant);
            this.applicants.splice(removeIndex,1);

            angular.forEach(me.taxReturns, function(tr){
            	tr.checkNumFilers(me.applicants.length);
            });



			applicant.removeRelationships();

			me.cleanHouseholds();

            if( this.applicants.length === 0 ){
                this.addApplicant('Applicant 1');
            }
		};

		Relationship.prototype.getOpposite = function(){
			return this.otherApplicant.getRelationship(this.applicant);
		};

		Relationship.prototype.updateOpposite = function(){
			var me = this;
			this.getOpposite().code = _.find(relationshipCodes, function(rc){
                    return rc.opposite == me.code;
            }).code;
		};

		Applicant.prototype.fields = [
			{app: 'isApplicant', api: 'Is Applicant', type: 'checkbox'},
			{app: 'disabled', api: 'Applicant Attest Blind or Disabled', type: 'checkbox'},
			{app: 'student', api: 'Student Indicator', type: 'checkbox'},
			{app: 'eligible', api: 'Medicare Entitlement Indicator', type: 'checkbox'},
			{app: 'incarcerated', api: 'Incarceration Status', type: 'checkbox'},
			{app: 'livesInState', api: 'Lives In State', type: 'checkbox'},
			{app: 'claimedByNonApplicant', api: 'Claimed as Dependent by Person Not on Application', type: 'checkbox'},
      		{app: 'longTermCare', api: 'Applicant Attest Long Term Care', type: 'checkbox'},
			{app: 'hasInsurance', api: 'Has Insurance', type: 'checkbox'},
			{app: 'stateEmployeeHealthBenefits', api: 'State Health Benefits Through Public Employee', type: 'checkbox'},
			{app: 'priorInsuranceIndicator', api: 'Prior Insurance', type: 'checkbox'},
			{app: 'pregnant', api: 'Applicant Pregnant Indicator', type: 'checkbox'},
			{app: 'pregnantThreeMonths', api: 'Applicant Post Partum Period Indicator', type: 'checkbox'},
			{app: 'formerlyFosterCare', api: 'Former Foster Care', type: 'checkbox'},
			{app: 'incomeTaxesRequired', api: 'Required to File Taxes', type: 'checkbox'},
			{app: 'citizen', api: 'US Citizen Indicator', type: 'checkbox'},
			{app: 'id', api: 'Person ID', type: 'string'},
			{app: 'age', api: 'Applicant Age', type: 'string'},
			{app: 'hours', api: 'Hours Worked Per Week', type: 'string'}
		];

	    Applicant.prototype.residencyFields = [
	      {app: 'temporarilyOutOfState', api: 'Temporarily Out of State', type: 'checkbox'},
	      {app: 'noFixedAddress', api: 'No Fixed Address', type: 'checkbox'}
	    ];

	    Applicant.prototype.claimedFields = [
	      {app: 'claimerIsOutOfState', api: 'Claimer Is Out of State', type: 'checkbox'}
	    ];

		Applicant.prototype.priorInsuranceFields = [
				{app: 'EndDate', api: 'Prior Insurance End Date', type: 'date'}
		];

	    Applicant.prototype.pregnantFields = [
	      {app: 'numberOfChildrenExpected', api: 'Number of Children Expected', type: 'string'}
	    ];

		Applicant.prototype.fosterCareFields = [
			{app: 'hadMedicaid', api: 'Had Medicaid During Foster Care', type: 'checkbox'},
			{app: 'ageLeftFosterCare', api: 'Age Left Foster Care', type: 'string'},
			{app: 'state', api: 'Foster Care State', type: 'state'}
		];

		Applicant.prototype.nonCitizenFields = [
      		{app: 'legalPermanentResident', api: 'Legal Permanent Resident', type: 'checkbox'},
			{app: 'lawful', api: 'Lawful Presence Attested', type: 'checkbox'},
			{app: 'fiveYearBar', api: 'Five Year Bar Applies', type: 'checkbox'},
			{app: 'fortyQuarters', api: 'Applicant Has 40 Title II Work Quarters', type: 'checkbox'},
			{app: 'fiveYearBarMet', api: 'Five Year Bar Met', type: 'checkbox'},
			{app: 'refugeeMedicalAssistanceEligible', api: 'Refugee Status', type: 'checkbox'},
			{app: 'humanTraffickingVictim', api: 'Victim of Trafficking', type: 'checkbox'}
		];

		Applicant.prototype.refugeeMedicalAssistanceFields = [
			{app: 'StartDate', api: 'Refugee Medical Assistance Start Date', type: 'date'}
		];

		Applicant.prototype.humanTraffickingFields = [
			{app: 'qualified', api: 'Qualified Non-Citizen Status', type: 'checkbox'},
			{app: 'deportWithheldDate', api: 'Non-Citizen Deport Withheld Date', type: 'date'},
			{app: 'entryDate', api: 'Non-Citizen Entry Date', type: 'date'},
			{app: 'statusGrantDate', api: 'Non-Citizen Status Grant Date', type: 'date'}
		];

		var serializeField = function(field, baseObject){
			if(field.type == 'checkbox'){
				return [field.api, baseObject[field.app] ? 'Y': 'N'];
			} else if(field.type == 'string'){
				return [field.api, baseObject[field.app]];
			} else if(field.type == 'date'){
				var month = baseObject[field.app].substring(0,2);
				var day = baseObject[field.app].substring(2,4);
				var year = baseObject[field.app].substring(4,8);
				return [field.api, year + "-" + month + "-" + day];
			} else if(field.type == 'state'){
		        return [field.api, baseObject[field.app].abbr];
      		}
		};

		var deserializeField = function(field, serializedObject){
			if(field.type == 'checkbox'){
				return serializedObject[field.api] == 'Y';
			} else if(field.type == 'string'){
				return serializedObject[field.api] || '';
			} else if(field.type == 'date'){
				if(serializedObject[field.api]){
					var month = serializedObject[field.api].substring(5,7);
					var day = serializedObject[field.api].substring(8,10);
					var year = serializedObject[field.api].substring(0,4);
					return month+day+year;
				}
				return "";
			} else if(field.type == 'state'){
		        return _.find(states, function(st){
		         	return st.abbr ==  serializedObject[field.api];
		        });
		    }
		};

		Applicant.prototype.serialize = function(){
			var me = this;

			var rv = _.map(this.fields, function(field){
				return serializeField(field,me);
			});

		    if(!(this.livesInState)){
        		rv = rv.concat(_.map(this.residencyFields, function(field){
            		return serializeField(field,me);
          		}));
      		}

	        if(this.claimedByNonApplicant){
	        	rv = rv.concat(_.map(this.claimedFields, function(field){
	            	return serializeField(field,me);
	          	}));
		    }

			if(this.priorInsuranceIndicator){
				rv = rv.concat(_.map(this.priorInsuranceFields, function(field){
					return serializeField(field,me.priorInsurance);
				}));
			}

	    	if(this.pregnant){
        		rv = rv.concat(_.map(this.pregnantFields, function(field){
            		return serializeField(field,me);
		        }));
	        }

			if(this.formerlyFosterCare){
				rv = rv.concat(_.map(this.fosterCareFields, function(field){
						return serializeField(field,me.fosterCare);
					}));
			}

			rv.push(['Income',me.incomeTaxes.serialize()]);

			if(!this.citizen){
				var ncOut = _.map(this.nonCitizenFields, function(field){
					return serializeField(field,me.nonCitizen);});
				if(this.nonCitizen.refugeeMedicalAssistanceEligible){
					$log.info('Eligible for Refugee Medical Assistance');
					ncOut = ncOut.concat(_.map(this.refugeeMedicalAssistanceFields, function(field){
						return serializeField(field,me.nonCitizen.refugeeMedicalAssistance);
					}));
				}
				if(this.nonCitizen.humanTraffickingVictim){
					ncOut = ncOut.concat(_.map(this.humanTraffickingFields, function(field){
						return serializeField(field,me.nonCitizen.humanTrafficking);
					}));
				}

				rv = rv.concat(ncOut);
			}

			rv.push(['Relationships', _.map(this.relationships, function(rel){
				return rel.serialize();
			})]);

			$log.info(rv);
			return _.object(rv);
		};


		Applicant.prototype.deserialize = function(person){
			var me = this;
			angular.forEach(this.fields, function(field){
				me[field.app] = deserializeField(field, person);
			});

		    angular.forEach(this.residencyFields, function(field){
		      me[field.app] = deserializeField(field, person);
		    });

		    angular.forEach(this.claimedFields, function(field){
		      me[field.app] = deserializeField(field, person);
		    });

		    me.priorInsurance = {};
			angular.forEach(this.priorInsuranceFields, function(field){
				me.priorInsurance[field.app] = deserializeField(field, person);
			});

		    angular.forEach(this.pregnantFields, function(field){
		        me[field.app] = deserializeField(field, person);
		    });

			me.fosterCare = {};

			angular.forEach(this.fosterCareFields, function(field){
				me.fosterCare[field.app] = deserializeField(field, person);
			});

			me.incomeTaxes = new IncomeTaxes().deserialize(person['Income']);

			me.nonCitizen = {
				refugeeMedicalAssistance: {},
				humanTrafficking: {}
			};

			angular.forEach(this.nonCitizenFields, function(field){
				me.nonCitizen[field.app] = deserializeField(field, person);
			});

			angular.forEach(this.refugeeMedicalAssistanceFields, function(field){
				me.nonCitizen.refugeeMedicalAssistance[field.app] = deserializeField(field, person);
			});

			angular.forEach(this.humanTraffickingFields, function(field){
				me.nonCitizen.humanTrafficking[field.app] = deserializeField(field, person);
			});

			return this;
		};

		Application.prototype.getApplicantById = function(id){
			return _.find(this.applicants, function(appl){
				return appl.id == id;
			});
		};


		Relationship.prototype.serialize = function(){
			return {
	          "Other ID": this.otherApplicant.id,
	          "Relationship Code": this.code
	        };
		};

		TaxReturn.prototype.serialize = function(){
			return {
				"Filers": _.chain(this.filers).filter(function(pers){return pers && pers.id && pers.id.length;}).map(function(pers){
					return {"Person ID": pers.id};
				}).value(),
				"Dependents": _.chain(this.dependents).filter(function(pers){ return pers.id && pers.id.length;}).map(function(pers){
					return {"Person ID": pers.id};
				}).value()
			};
		};

		TaxReturn.prototype.deserialize = function(application, obj){
			var me = this;
			this.filers = _.map(obj["Filers"], function(obj){
				return application.getApplicantById(obj["Person ID"]);
			});
			this.dependents = _.map(obj["Dependents"], function(obj){
				return application.getApplicantById(obj["Person ID"]);
			});

			return this;
		};

		Application.prototype.serialize = function(){
			var st;
			if(this.state){
				st = this.state.abbr;
			} else{
				st = "";
			}

			return {
				"State": st,
				"Name": this.applicationId,
				"People": _.map(this.applicants,
					function(applicant){return applicant.serialize();}),
				"Physical Households": _.map(this.households, function(hh, idx){
					return {
						"Household ID": "Household" + (idx+1),
						"People": _.map(hh, function(applicant){
							return {"Person ID": applicant.id};
						})
					};
				}),
				"Tax Returns": _.map(this.taxReturns, function(tr){return tr.serialize();})
			};
		};

		Application.prototype.deserialize = function(application){
			// Load applicants sans-relationships
			var me = this;
			this.applicants = _.map(application["People"], function(person){
				return new Applicant().deserialize(person);
			});

			this.taxReturns = _.map(application["Tax Returns"], function(taxReturn){
				var tr = new TaxReturn().deserialize(me, taxReturn);
				tr.checkNumFilers(application["People"].length);
				return tr;
			});

			this.households = _.map(application["Physical Households"], function(hh){
				return _.map(hh["People"], function(person){
					return me.getApplicantById(person["Person ID"]);
				});
			});


			this.applicationId = application["Name"];
			this.state = _.find(states, function(st){
				return st.abbr == application["State"];
			});

			if(!this.state){
				this.state = {};
			}

			angular.forEach(application["People"], function(person){
				var pers = me.getApplicantById(person["Person ID"]);
				pers.relationships = _.map(person["Relationships"], function(rel){
					return new Relationship(pers, me.getApplicantById(rel["Other ID"]), rel['Relationship Code']);
				});
			});

			$log.info("Deserializing");
			$log.info(this);
		};

		Application.prototype.resetResults = function(){
			this.determination = {};
		};

		// Returns a promise of a result.
		Application.prototype.checkEligibility = function(){
			var app = this.serialize();
			var me = this;
			return $http({
				url: "/determinations/eval.json",
				method: "POST",
				data: app
			}).success(function(response){
				$log.info(response);
				me.determination = response;
				angular.forEach(me.determination["Applicants"], function(applicant){
					applicant.cleanDets = _.map(_.pairs(applicant.Determinations), function(item){
						return {
							item: item[0], 
							indicator: item[1]["Indicator"],
							code: item[1]["Ineligibility Code"],
              reason: item[1]["Ineligibility Reason"]
						};
					});					
				});
				
				return response;
            }).error(function(error){
				$log.error(error);
			});
		};

		return new Application();
	}]).
	constant('relationshipCodes',
		[
            {code: '02', label: 'Spouse', opposite: '02'},
            {code: '03', label: 'Parent', opposite: '04'},
            {code: '04', label: 'Child', opposite: '03'},
            {code: '05', label: 'Stepchild', opposite: '12'},
            {code: '06', label: 'Grandchild', opposite: '15'},
            {code: '07', label: 'Sibling/Stepsibling', opposite: '07'},
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
            {code: '70', label: "Domestic partner's child", opposite: '17'},
            {code: '88', label: "Other", opposite: '88'}
        ]).
	constant('states',[
	    {abbr: 'AL', name: 'Alabama', inApp: true},
            {abbr: 'AK', name: 'Alaska', inApp: true},
            {abbr: 'AZ', name: 'Arizona', inApp: true},
            {abbr: 'AR', name: 'Arkansas', inApp: true},
            {abbr: 'CA', name: 'California'},
            {abbr: 'CO', name: 'Colorado'},
            {abbr: 'CT', name: 'Connecticut'},
            {abbr: 'DE', name: 'Delaware', inApp: true},
            {abbr: 'DC', name: 'District Of Columbia'},
            {abbr: 'FL', name: 'Florida', inApp: true},
            {abbr: 'GA', name: 'Georgia', inApp: true},
            {abbr: 'GU', name: 'Guam'},
            {abbr: 'HI', name: 'Hawaii'},
            {abbr: 'ID', name: 'Idaho', inApp: true},
            {abbr: 'IL', name: 'Illinois', inApp: true},
            {abbr: 'IN', name: 'Indiana', inApp: true},
            {abbr: 'IA', name: 'Iowa', inApp: true},
            {abbr: 'KS', name: 'Kansas', inApp: true},
            {abbr: 'KY', name: 'Kentucky'},
            {abbr: 'LA', name: 'Louisiana', inApp: true},
            {abbr: 'ME', name: 'Maine', inApp: true},
            {abbr: 'MD', name: 'Maryland', inApp: true},
            {abbr: 'MA', name: 'Massachusetts'},
            {abbr: 'MI', name: 'Michigan', inApp: true},
            {abbr: 'MN', name: 'Minnesota'},
            {abbr: 'MS', name: 'Mississippi', inApp: true},
            {abbr: 'MO', name: 'Missouri', inApp: true},
            {abbr: 'MT', name: 'Montana', inApp: true},
            {abbr: 'NE', name: 'Nebraska', inApp: true},
            {abbr: 'NV', name: 'Nevada'},
            {abbr: 'NH', name: 'New Hampshire', inApp: true},
            {abbr: 'NJ', name: 'New Jersey', inApp: true},
            {abbr: 'NM', name: 'New Mexico', inApp: true},
            {abbr: 'NY', name: 'New York'},
            {abbr: 'NC', name: 'North Carolina', inApp: true},
            {abbr: 'ND', name: 'North Dakota', inApp: true},
            {abbr: 'OH', name: 'Ohio', inApp: true},
            {abbr: 'OK', name: 'Oklahoma', inApp: true},
            {abbr: 'OR', name: 'Oregon'},
            {abbr: 'PA', name: 'Pennsylvania', inApp: true},
            {abbr: 'RI', name: 'Rhode Island'},
            {abbr: 'SC', name: 'South Carolina', inApp: true},
            {abbr: 'SD', name: 'South Dakota', inApp: true},
            {abbr: 'TN', name: 'Tennessee', inApp: true},
            {abbr: 'TX', name: 'Texas', inApp: true},
            {abbr: 'UT', name: 'Utah', inApp: true},
            {abbr: 'VT', name: 'Vermont'},
            {abbr: 'VA', name: 'Virginia', inApp: true},
            {abbr: 'WA', name: 'Washington'},
            {abbr: 'WV', name: 'West Virginia', inApp: true},
            {abbr: 'WI', name: 'Wisconsin', inApp: true},
            {abbr: 'WY', name: 'Wyoming', inApp: true}
		]);
