var state_dln_patterns= {
    "AL": {
      "regex": "^[0-9]{7,8}$"
    },
    "AK": {
      "regex": "^[0-9]{7}$"
    },
    "AZ": {
      "regex": "^{[a-zA-Z][0-9]{8}|[0-9]{9}$"
    },
    "AR": {
      "regex": "^[0-9]{9}$"
    },
    "CA": {
      "regex": "^[a-zA-Z][0-9]{7}$"
    },
    "CO": {
      "regex": "^[0-9]{9}$"
    },
    "CT": {
      "regex": "^[0-9]{9}$"
    },
    "DE": {
      "regex": "^[0-9]{1,7}$"
    },
    "DC": {
      "regex": "^[0-9]{7}$"
    },
    "FL": {
      "regex": "^[a-zA-Z][0-9]{12}$"
    },
    "GA": {
      "regex": "^[0-9]{9}$"
    },
    "HI": {
      "regex": "^([Hh][0-9]{8}|[0-9]{9})$"
    },
    "ID": {
      "regex": "^[a-zA-Z]{2}[0-9]{6}[a-zA-Z]$"
    },
    "IL": {
      "regex": "^[a-zA-Z][0-9]{11}$"
    },
    "IN": {
      "regex": "^[0-9]{10}$"
    },
    "IA": {
      "regex": "^([0-9]{9}|[0-9]{3}[a-zA-Z]{2}[0-9]{4}$"
    },
    "KS": {
      "regex": "^[kK][0-9]{8}$"
    },
    "KY": {
      "regex": "^[a-zA-Z][0-9]{8}$"
    },
    "LA": {
      "regex": "^0[0-9]{7}$"
    },
    "ME": {
      "regex": "^[0-9]{7}$"
    },
    "MD": {
      "regex": "^[a-zA-Z][0-9]{12}$"
    },
    "MA": {
      "regex": "^[a-zA-Z][0-9]{8}$"
    },
    "MI": {
      "regex": "^[a-zA-Z][0-9]{12}$"
    },
    "MN": {
      "regex": "^[a-zA-Z][0-9]{12}$"
    },
    "MS": {
      "regex": "^[0-9]{9}$"
    },
    "MO": {
      "regex": "^([a-zA-Z][0-9]{5,9}|[0-9]{9})$"
    },
    "MT": {
      "regex": "^([0-9]{9}|[0-9]{13})$"
    },
    "NE": {
      "regex": "^[a-zA-Z][0-9]{3,8}$"
    },
    "NV": {
      "regex": "^([0-9]{9,10}|[0-9]{12}|[xX][0-9]{8})$"
    },
    "NH": {
      "regex": "^([0-9]{2}[a-zA-Z]{3}[0-9]{5}|[a-zA-Z]{3}[0-9]{8}$"
    },
    "NJ": {
      "regex": "^[a-zA-Z][0-9]{14}$"
    },
    "NM": {
      "regex": "^[0-9]{9}$"
    },
    "NY": {
      "regex": "^[0-9]{9}$"
    },
    "NC": {
      "regex": "^[0-9]{1,12}$"
    },
    "ND": {
      "regex": "^([a-zA-Z]{3}[0-9]{6}|[0-9]{9})$"
    },
    "OH": {
      "regex": "^[a-zA-Z]{2}[0-9]{6}$"
    },
    "OK": {
      "regex": "^([a-zA-Z]{0,1}[0-9]{9}$"
    },
    "OR": {
      "regex": "^[0-9]{1,7}$"
    },
    "PA": {
      "regex": "^[0-9]{8}$"
    },
    "RI": {
      "regex": "^([0-9]{7}|[vV][0-9]{6})$"
    },
    "SC": {
      "regex": "^([0-9]{11}|[0-9]{9})$"
    },
    "SD": {
      "regex": "^([0-9]{6}|[0-9]{8,9})$"
    },
    "TN": {
      "regex": "^[0-9]{7,9}$"
    },
    "TX": {
      "regex": "^[0-9]{8}$"
    },
    "UT": {
      "regex": "^[0-9]{4,10}$"
    },
    "VT": {
      "regex": "^([0-9]{8}|[0-9]{7}[aA])$"
    },
    "VA": {
      "regex": "^([a-zA-Z][0-9]{8}|[0-9]{9})$"
    },
    "WA": {
      "regex": "^([a-zA-Z][a-zA-Z0-9\\*]{11}|[a-zA-Z]{7}[0-9]{3)[a-zA-Z]{2})$"
    },
    "WV": {
      "regex": "^[a-zA-Z]{1,2}[0-9]{5,6}$"
    },
    "WI": {
      "regex": "^[a-zA-Z][0-9]{13}$"
    },
    "WY": {
      "regex": "^[0-9]{9}$"
    }
  };

  function al_update_dln_pattern($select, $) {
    var state = $select.val();
    var record = state_dln_patterns[state];
    if (record) {
        var pattern = record['regex'];
        var message_pattern=  $('input[name="abr[drivers_license_number]"').closest('li').data('ui-regexp-fail-message-pattern');
        var error_message = message_pattern.replace(/%state%/gi, state);
        //For matching
        $('input[name="abr[drivers_license_number]"').closest('li').attr('data-ui-regexp',pattern);
        $('input[name="abr[drivers_license_number]"').closest('li').attr('data-ui-regexp-fail-message',error_message);
        //For data
        $('input[name="abr[drivers_license_number]"').closest('li').data('ui-regexp',pattern);
        $('input[name="abr[drivers_license_number]"').closest('li').data('ui-regexp-fail-message',error_message);
        
        
    }
    else {
        $('input[name="abr[drivers_license_number]"').closest('li').data('ui-regexp','');
        $('input[name="abr[drivers_license_number]"').closest('li').data('ui-regexp-fail-message',"");
    }
    $select.closest('form').change();
  }

  jQuery(document).ready(function($) {
    $('select[name="abr[drivers_license_state]"').on('change', function () {
        al_update_dln_pattern ($(this), $)});
  });