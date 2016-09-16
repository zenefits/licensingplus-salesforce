import _ from 'lodash';
import moment from 'moment';
import * as http from 'http';

var Utils = {
  csvDelimiter: ',',
  lowKey: function (obj) {
    if (obj) {
      return _.mapKeys(obj, function (val, key) {
        return key.toLowerCase();
      });
    }
    else {
      return null;
    }
  },
  lowKeyArray: function (arr) {
    return _.map(arr, (obj) => {
      return this.lowKey(obj);
    })
  },

  formatSfdcDate: function (mom) {
    if (moment.isMoment(mom)) {
      return mom.format('YYYY-MM-DD');
    }
    else {
      return moment(mom).format('YYYY-MM-DD');
    }
  },

  formatSfdcDateTime: function (mom) {
    if (moment.isMoment(mom)) {
      return mom.format('YYYY-MM-DD hh:mm:ss');
    }
    else {
      return moment(mom).format('YYYY-MM-DD hh:mm:ss');
    }
  },

  checkSyntax: function (logic, length) {
    var isValidExpression;
    //expression string isvalid
    if (logic) {
      var expression = logic.replace(/\d+/g, 'true');
      expression = expression.replace(/\and/g, '&&');
      expression = expression.replace(/\or/g, '||');
      try {
        eval(expression)
        isValidExpression = true;
      }
      catch (e) {
        isValidExpression = false;
      }

      var num = logic.match(/\d+/g);
      var numbers = [];
      if (num) {
        numbers = logic.match(/\d+/g).sort();
      }

      //numbers cannot repeat
      var isValidUnique;
      if (_.uniq(numbers).length === numbers.length) {
        isValidUnique = true
      }
      else {
        isValidUnique = false;
      }

      var isValidNumbers;
      //expression only contains certain numbers
      if (parseInt(numbers.pop(), 10) === length) {
        isValidNumbers = true;
      }
      else {
        isValidNumbers = false;
      }

      return isValidExpression && isValidUnique && isValidNumbers;
    } else if (!logic && length) {
      return false;
    } else if (logic && !length) {
      return false;
    } else {
      return true;
    }
  },

  convertDbLogicToUi: function (logic) {
    if (logic) {
      var splitLogic = _.split(logic, /(&|\||\s|\(|\))/g);
      var logicIndex = 1
      _.each(splitLogic, function (value, index) {
        if (value.length > 14) {
          splitLogic[index] = logicIndex;
          logicIndex++;
        }
      })
      var splitLogicStr = splitLogic.toString().replace(/,/g, '');
      splitLogicStr = _.unescape(splitLogicStr);
      splitLogicStr = splitLogicStr.replace(/\&/g, 'and');
      splitLogicStr = splitLogicStr.replace(/\|/g, 'or');
      return splitLogicStr;
    }
  },

  convertUiLogicToDb: function (logic) {
    if (logic) {
      var splitLogic = logic.replace(/\d+/g, function (n) { return '{' + n + '}'; })
      splitLogic = splitLogic.toString().replace(/\and/g, '&');
      splitLogic = splitLogic.toString().replace(/\or/g, '|');
      return splitLogic;
    }
  },

  get: function (element) {
    if (!element.nodeType) {
      return document.getElementById(element);
    }
    return element;
  },

  fixCSVField: function (value) {
    var fixedValue = value;
    var addQuotes = (value.indexOf(this.csvDelimiter) !== -1) || (value.indexOf('\r') !== -1) || (value.indexOf('\n') !== -1);
    var replaceDoubleQuotes = (value.indexOf('"') !== -1);

    if (replaceDoubleQuotes) {
      fixedValue = fixedValue.replace(/"/g, '""');
    }
    if (addQuotes || replaceDoubleQuotes) {
      fixedValue = '"' + fixedValue + '"';
    }
    return fixedValue;
  },

  tableToCSV: function (table) {
    var data = "";
    var csvNewLine = "\r\n";
    var i, j, row, col;
    for (i = 0; i < table.rows.length; i++) {
      row = table.rows[i];
      for (j = 0; j < row.cells.length; j++) {
        col = row.cells[j];
        data = data + (j ? this.csvDelimiter : '') + this.fixCSVField(col.textContent.trim());
      }
      data = data + csvNewLine;
    }
    return data;
  },

  exportToCSV: function (tableID, fileName) {
    let tableElement = this.get(tableID);
    var csvData = this.tableToCSV(tableElement);
    var hrefvalue = 'data:text/csv;charset=UTF-8,' + encodeURIComponent(csvData);
    var a = document.createElement('a');
    a.href = hrefvalue;
    a.target = '_blank';
    a.download = fileName;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  }
};

export default Utils