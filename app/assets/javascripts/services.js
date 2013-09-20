angular.module('MAGI.services',[]).
	factory('Application', function(relationshipCodes){
		function Application(){
			this.applicants = [];
			this.taxReturns = [];
		}

		function TaxReturn(){
			this.filers = [];
			this.dependents = [];
		}

		function Applicant(){
			this.citizen = true;
			this.stateResidency = true;
			this.isApplicant = true;
			this.relationships = [];
		}

		function Relationship(applicant, otherApplicant, code){
			this.applicant = applicant;
			this.otherApplicant = otherApplicant;
			this.code = code;
		}

		// Note. Remove this eventually. UI should not have to deal with service
		// For now, sets the number of filers and dependents in a tax return to 
		// be an appropriate amount for the number of applicants
		TaxReturn.prototype.checkNumFilers = function(numApplicants){
			var numFilers = Math.min(numApplicants,2);
			while(this.filers.length < numFilers){
                    this.filers.push({});
            }
            while(this.filers.length > numFilers){
                    this.filers.pop();
            }
            
            var numDependents = Math.max(numApplicants-1,0);
            while(this.dependents.length < numDependents){
                    this.dependents.push({});
            }
            while(this.dependents.length > numDependents){
                    this.dependents.pop();
            }
		}

		Application.prototype.addTaxReturn = function(){
			var taxReturn = new TaxReturn();
			taxReturn.checkNumFilers(this.applicants.length);
			this.taxReturns.push(taxReturn);
		}

		Application.prototype.removeTaxReturn = function(taxReturn){
			this.taxReturns.splice(this.taxReturns.indexOf(taxReturn),1);
            if(this.taxReturns.length == 0){
            	this.addTaxReturn();
            }
		}

		Application.prototype.addApplicant = function(applicantName){
			var applicant = new Applicant();
			applicant.id = applicantName;

			angular.forEach(this.applicants, function(other){
				other.addRelationship(applicant);
				applicant.addRelationship(other);
			});

			this.applicants.push(applicant);
			var appl = this;

			angular.forEach(this.taxReturns, function(taxReturn){
				taxReturn.checkNumFilers(appl.applicants.length)
			});
		}

		Applicant.prototype.addRelationship = function(other){
			this.relationships.push(new Relationship(this, other, ''));
		};

		Applicant.prototype.getRelationship = function(otherApplicant){
			return _.find(this.relationships, function(rel){
				return rel.otherApplicant == otherApplicant;
			});
		}

		Applicant.prototype.removeRelationship = function(otherApplicant){
			var toRemove = this.getRelationship(otherApplicant);
			var idx = this.relationships.indexOf(toRemove);
            this.relationships.splice(idx, 1);
		}

		Applicant.prototype.removeRelationships = function(){
			angular.forEach(this.relationships, function(rel){
				rel.otherApplicant.removeRelationship(this);
			});
		}

		Application.prototype.removeApplicant = function(applicant){
			applicant.removeRelationships();
			var removeIndex = this.applicants.indexOf(applicant);
            this.applicants.splice(removeIndex,1);
            
            if( this.applicants.length == 0 ){
                        	this.addApplicant();
            }
		}

		Relationship.prototype.getOpposite = function(){
			return this.otherApplicant.getRelationship(this.applicant);
		}

		Relationship.prototype.updateOpposite = function(){
			var me = this;
			this.getOpposite().code = _.filter(relationshipCodes, function(rc){
                    return rc.code == me.code;
            });
		}

		return new Application();

	})
	.constant('relationshipCodes',
		[
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
	).constant('states',[
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
		]
	);