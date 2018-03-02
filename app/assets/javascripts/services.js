angular.module('MAGI.services',[]).
    factory('Application', ['$http','$log','relationshipCodes','states','$location', function($http,$log,relationshipCodes,states,$location){
    applicant_ids = 0;

    function Application(){
      this.applicants = [];
      this.taxReturns = [];
      // get the state from the URL if it is set
      this.state = _.find(states, function(st){
        return st.abbr == ($location.search()).state;
      });
      var today = new Date();
      if (($location.search()).year) {
        this.applicationYear = parseInt(($location.search()).year);  
      } else if (today.getMonth() >= 3) {
        this.applicationYear = today.getFullYear();
      } else {
        this.applicationYear = today.getFullYear() + 1;
      }
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
      this.qnc = {};
      this.refugeeMedicalAssistance = {};
      this.fosterCare = {
        state: {}
        };
    }

    function Relationship(applicant, otherApplicant, code, primaryResponsibility){
      this.applicant = applicant;
      this.otherApplicant = otherApplicant;
      this.code = code;
      this.primaryResponsibility = primaryResponsibility;
    }

    function IncomeTaxes(){
      var me = this;
    }

    IncomeTaxes.prototype.fields = [
        {app: 'monthly',            api:'Monthly Income'},
        {app: 'wages',              api:'Wages, Salaries, Tips'},
        {app: 'taxableInterest',    api: 'Taxable Interest'},
        {app: 'taxExemptInterest',  api:'Tax-Exempt Interest'},
        {app: 'taxableRefunds',     api: 'Taxable Refunds, Credits, or Offsets of State and Local Income Taxes'},
        {app: 'alimony',            api: 'Alimony'},
        {app: 'capitalGains',       api: 'Capital Gain or Loss'},
        {app: 'pensions',           api: 'Pensions and Annuities Taxable Amount'},
        {app: 'farmIncome',         api: 'Farm Income or Loss'},
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

    TaxReturn.prototype.canAddFiler = function(application){
      return (this.filers.length < 2 ) && (this.filers.length < application.applicants.length);
    };

    TaxReturn.prototype.canAddDependent = function(application){
      return (this.filers.length > 0) && (this.dependents.length < application.applicants.length - 1);
    };

    TaxReturn.prototype.addFiler = function(applicant){
      this.filers.push(applicant);
    };

    TaxReturn.prototype.removeFiler = function(applicant){
      //this.filers.pop(applicant);
      this.filers.splice(this.filers.indexOf(applicant), 1);
    };

    TaxReturn.prototype.addDependent = function(applicant){
      this.dependents.push(applicant);
    };

    TaxReturn.prototype.removeDependent = function(applicant){
      this.dependents.splice(this.dependents.indexOf(applicant), 1)
    };

    Application.prototype.addTaxReturn = function(){
      var taxReturn = new TaxReturn();
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
      applicant.rawId = applicantName;

      applicant_ids++;
      applicant.uid = applicant_ids;

      angular.forEach(this.applicants, function(other){
        other.addRelationship(applicant);
        applicant.addRelationship(other);
      });

      this.applicants.push(applicant);
      this.households[0].push(applicant);
      var appl = this;
    };

    Applicant.prototype.addRelationship = function(other){
      this.relationships.push(new Relationship(this, other, '', false));
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
      var me = this;
      angular.forEach(this.relationships, function(rel){
        rel.otherApplicant.removeRelationship(me);
      });
    };

    Applicant.prototype.addResponsibility = function(otherApplicant) {
      this.getRelationship(otherApplicant).primaryResponsibility = true;
    }

    Application.prototype.clearResponsibility = function(dependent) {
      angular.forEach(this.applicants, function(applicant) {
        rel = applicant.getRelationship(dependent);
        if (rel) {
          applicant.getRelationship(dependent).primaryResponsibility = false;
        }
      });
    }

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

      applicant.removeRelationships();

      var removeIndex = this.applicants.indexOf(applicant);

      angular.forEach(me.applicants, function(appl, idx){
        if (idx > removeIndex && appl.uid == (idx + 1)) {
          appl.uid = idx;
        }
      });

      this.applicants.splice(removeIndex,1);

      me.cleanHouseholds();

      applicant_ids--;

      if( this.applicants.length === 0 ){
        this.addApplicant("Applicant 1");
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

    Applicant.prototype.getName = function(){
      return "Applicant ".concat(this.uid.toString());
    }

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
      //{app: 'id', api: 'Person ID', type: 'string'},
      {app: 'age', api: 'Applicant Age', type: 'string'},
      {app: 'age90OrOlder', api: 'Applicant Age >= 90', type: 'checkbox'},
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
      {app: 'lawful', api: 'Lawful Presence Attested', type: 'checkbox'}
    ];

    Applicant.prototype.lawfulPresentFields = [
      {app: 'immigrationStatus', api: 'Immigration Status', type: 'immigrationStatus'},
      {app: 'refugeeMedicalAssistanceEligible', api: 'Refugee Status', type: 'checkbox'}
    ];

    Applicant.prototype.qualifiedNonCitizenFields = [
      {app: 'amerasian', api: 'Amerasian Immigrant', type: 'checkbox'},
      {app: 'veteran', api: 'Veteran Status', type: 'checkbox'},
      {app: 'humanTraffickingVictim', api: 'Victim of Trafficking', type: 'checkbox'},
      {app: 'sevenYearStartDate', api: 'Seven Year Limit Start Date', type: 'date'},
      {app: 'fiveYearBar', api: 'Five Year Bar Applies', type: 'checkbox'},
      {app: 'fiveYearBarMet', api: 'Five Year Bar Met', type: 'checkbox'},
      {app: 'fortyQuarters', api: 'Applicant Has 40 Title II Work Quarters', type: 'checkbox'}
    ];

    Applicant.prototype.refugeeMedicalAssistanceFields = [
      {app: 'startDate', api: 'Refugee Medical Assistance Start Date', type: 'date'}
    ];

    var serializeField = function(field, baseObject){
      if(field.type == 'checkbox'){
        return [field.api, baseObject[field.app] ? 'Y': 'N'];
      } else if(field.type == 'string'){
        return [field.api, baseObject[field.app]];
      } else if(field.type == 'date'){
        if(baseObject[field.app]){
          var month = baseObject[field.app].substring(0,2);
          var day = baseObject[field.app].substring(2,4);
          var year = baseObject[field.app].substring(4,8);
          return [field.api, year + "-" + month + "-" + day];
        } else {
          return [field.api, null];
        }
      } else if(field.type == 'state'){
        return [field.api, baseObject[field.app].abbr];
      } else if(field.type == 'immigrationStatus') {
        return [field.api, baseObject[field.app].code];
      }
    };

    var deserializeField = function(field, serializedObject){
      if(field.type == 'checkbox'){
        return serializedObject[field.api] == 'Y';
      } else if(field.type == 'string'){
        if(serializedObject[field.api] == 0) {
          return 0;
        } else {
          return serializedObject[field.api] || '';
        }
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

      rv.push(['Person ID',me.uid]);

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
        if (this.nonCitizen.lawful) {
          ncOut = ncOut.concat(_.map(this.lawfulPresentFields, function(field){
            return serializeField(field, me.lawful);
          }));
          if (this.lawful.immigrationStatus.qnc) {
            ncOut = ncOut.concat(_.map(this.qualifiedNonCitizenFields, function(field){
              return serializeField(field, me.qnc);
            }));
          }
          if(this.lawful.refugeeMedicalAssistanceEligible){
            ncOut = ncOut.concat(_.map(this.refugeeMedicalAssistanceFields, function(field){
              return serializeField(field,me.refugeeMedicalAssistance);
            }));
          }
        }

        rv = rv.concat(ncOut);
      }

      rv.push(['Relationships', _.map(this.relationships, function(rel){
        return rel.serialize();
      })]);

      $log.info(rv);
      return _.object(rv);
    };


    Applicant.prototype.deserialize = function(person, idx){
      var me = this;

      me.uid = idx + 1;
      me.rawId = person["Person ID"];

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

      me.nonCitizen = {};

      me.lawful = {};

      me.qnc = {};

      me.refugeeMedicalAssistance = {};

      angular.forEach(this.nonCitizenFields, function(field){
        me.nonCitizen[field.app] = deserializeField(field, person);
      });

      angular.forEach(this.lawfulPresentFields, function(field){
        me.lawful[field.app] = deserializeField(field, person);
      });

      angular.forEach(this.qualifiedNonCitizenFields, function(field){
        me.qnc[field.app] = deserializeField(field, person);
      });

      angular.forEach(this.refugeeMedicalAssistanceFields, function(field){
        me.refugeeMedicalAssistance[field.app] = deserializeField(field, person);
      });

      return this;
    };

    Application.prototype.getApplicantByRawId = function(id){
      return _.find(this.applicants, function(appl){
        return appl.rawId == id;
      });
    };

    Application.prototype.getApplicantByUid = function(uid){
      return _.find(this.applicants, function(appl){
        return appl.uid == uid;
      });
    };

    Relationship.prototype.serialize = function(){
      return {
            "Other ID": this.otherApplicant.uid,
            "Relationship Code": this.code,
            "Attest Primary Responsibility": (this.primaryResponsibility ? "Y" : "N")
          };
    };

    TaxReturn.prototype.serialize = function(){
      return {
        "Filers": _.chain(this.filers).filter(function(pers){return pers && pers.uid;}).map(function(pers){
          return {"Person ID": pers.uid};
        }).value(),
        "Dependents": _.chain(this.dependents).filter(function(pers){ return pers.uid;}).map(function(pers){
          return {"Person ID": pers.uid};
        }).value()
      };
    };

    TaxReturn.prototype.deserialize = function(application, obj){
      var me = this;
      this.filers = _.map(obj["Filers"], function(obj){
        return application.getApplicantByRawId(obj["Person ID"]);
      });
      this.dependents = _.map(obj["Dependents"], function(obj){
        return application.getApplicantByRawId(obj["Person ID"]);
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
        "Application Year": this.applicationYear,
        "Name": "Frontend Application",
        "People": _.map(this.applicants,
          function(applicant){return applicant.serialize();}),
        "Physical Households": _.map(this.households, function(hh, idx){
          return {
            "Household ID": "Household" + (idx+1),
            "People": _.map(hh, function(applicant){
              return {"Person ID": applicant.uid};
            })
          };
        }),
        "Tax Returns": _.map(this.taxReturns, function(tr){return tr.serialize();})
      };
    };

    Application.prototype.deserialize = function(application){
      // Load applicants sans-relationships
      var me = this;

      this.applicants = []
      angular.forEach(application["People"], function(person, idx){
        this.applicants.push(new Applicant().deserialize(person, idx));
      });

      //this.applicants = _.map(application["People"], function(person){
      //  return new Applicant().deserialize(person);
      //});

      this.taxReturns = _.map(application["Tax Returns"], function(taxReturn){
        var tr = new TaxReturn().deserialize(me, taxReturn);
        return tr;
      });

      this.households = _.map(application["Physical Households"], function(hh){
        return _.map(hh["People"], function(person){
          return me.getApplicantByRawId(person["Person ID"]);
        });
      });


      this.state = _.find(states, function(st){
        return st.abbr == application["State"];
      });

      if(!this.state){
        this.state = {};
      }

      angular.forEach(application["People"], function(person){
        var pers = me.getApplicantByRawId(person["Person ID"]);
        pers.relationships = _.map(person["Relationships"], function(rel){
          return new Relationship(pers, me.getApplicantByRawId(rel["Other ID"]), rel['Relationship Code'], (rel['Attest Primary Responsibility'] == 'Y'));
        });
      });

      angular.forEach(this.applicants, function(person){
        person.nonParentResponsibility = false;
        angular.forEach(this.applicants, function(person2) {
          rel = person2.getRelationship(person);
          if (rel.primaryResponsibility) {
            person.nonParentResponsibility = true;
          }
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
        data: app,
        headers: {"Authorization": "Token token=".concat(gon.accessToken)}
      }).success(function(response){
        $log.info(response);
        me.determination = response;
        angular.forEach(me.determination["Applicants"], function(applicant){
          applicant.cleanDets = _.map(_.pairs(applicant.Determinations), function(item){
            // Suppress some stuff for North Dakota
            var hide = false;
            var indicator = item[1]["Indicator"];

            if (me.state.abbr == 'ND') {
              if (item[0] == "Medicaid Citizen Or Immigrant" && applicant["Medicaid Category"] == "None") {
                hide = true;
              } else if (item[0] == "CHIP Citizen Or Immigrant" && (applicant["CHIP Category"] == "None" || applicant["Medicaid Eligible"] == "Y")) {
                hide = true;
              }
            }

            return {
              item: item[0], 
              indicator: indicator,
              code: item[1]["Ineligibility Code"],
              reason: item[1]["Ineligibility Reason"],
              hide: hide
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
            {code: '17', label: "Parent's domestic partner", opposite: '70'},
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
            {abbr: 'DC', name: 'District Of Columbia', inApp: true},
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
            {abbr: 'NJ', name: 'New Jersey', inApp: true,},
            {abbr: 'NM', name: 'New Mexico', inApp: true},
            {abbr: 'NY', name: 'New York'},
            {abbr: 'NC', name: 'North Carolina', inApp: true},
            {abbr: 'ND', name: 'North Dakota', inApp: true,},
            {abbr: 'OH', name: 'Ohio', inApp: true},
            {abbr: 'OK', name: 'Oklahoma', inApp: true},
            {abbr: 'OR', name: 'Oregon'},
            {abbr: 'PA', name: 'Pennsylvania', inApp: true},
            {abbr: 'RI', name: 'Rhode Island'},
            {abbr: 'SC', name: 'South Carolina', inApp: true},
            {abbr: 'SD', name: 'South Dakota', inApp: true},
            {abbr: 'TN', name: 'Tennessee', inApp: true,},
            {abbr: 'TX', name: 'Texas', inApp: true},
            {abbr: 'UT', name: 'Utah', inApp: true},
            {abbr: 'VT', name: 'Vermont'},
            {abbr: 'VA', name: 'Virginia', inApp: true},
            {abbr: 'WA', name: 'Washington'},
            {abbr: 'WV', name: 'West Virginia', inApp: true},
            {abbr: 'WI', name: 'Wisconsin', inApp: true},
            {abbr: 'WY', name: 'Wyoming', inApp: true}
    ]).
  constant('applicationYears', [2013,2014,2015,2016,2017,2018]).
  constant('applicationStatuses', [
    {code: "01", name: "Lawful Permanent Resident (LPR/Green Card Holder)", qnc: true, startDate: "Entry date"},
    {code: "02", name: "Asylee", qnc: true, startDate: "Asylum grant date"},
    {code: "03", name: "Refugee", qnc: true, startDate: "Refugee admit date"},
    {code: "04", name: "Cuban/Haitian entrant", qnc: true, startDate: "Status grant date"},
    {code: "05", name: "Paroled into the U.S. for at least one year", qnc: true},
    {code: "06", name: "Conditional entrant granted before 1980", qnc: true},
    {code: "07", name: "Battered non-citizen, spouse, child, or parent", qnc: true},
    {code: "08", name: "Victim of trafficking", qnc: true},
    {code: "09", name: "Granted withholding of deportation", qnc: true, startDate: "Deportation withheld date"},
    {code: "10", name: "Member of a federally recognized Indian tribe or American Indian born in Canada", qnc: true},
    {code: "99", name: "Other", qnc: false}
  ]);
