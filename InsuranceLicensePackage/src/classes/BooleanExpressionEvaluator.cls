/**
	Dummy boolean expression evaluator which can evaluate string like 
	'false | (true | false)' or 'false & (true | false)', no look ahead yet
 **/
public with sharing class BooleanExpressionEvaluator {
	private final List<String> content;
	private String currentChar;
	private Integer currentIndex;
	private final String EOF = '$';
	
	public BooleanExpressionEvaluator(String line) {
		this.content = line.split('');
		this.content.add(EOF);
		this.currentIndex = 0;
	}
	
	public void nextChar()  {
		this.currentChar = this.content[currentIndex];
		this.currentIndex += 1;
		while(this.currentChar != EOF &&
				(this.currentChar == ' ' || this.currentChar == '\t' || this.currentChar == '\n' || this.currentChar == '\r')) {
			this.currentChar = this.content[this.currentIndex];
			this.currentIndex += 1;
		}
	}
	
	public Boolean eval() {
		nextChar();
		if (this.currentChar == EOF) {
			return false;
		}
		return matchOr();
	}
	
	private Boolean matchOr() {
		Boolean iResult = matchAnd();
		
		while (this.currentChar == '|') {
			nextChar();
			if (this.currentChar == EOF) {
				break;
			}
			iResult |= matchAnd();
		}
		
		return iResult;
	}
	
	private Boolean matchAnd() {
		Boolean iResult = matchOperand();
		
		while (this.currentChar == '&') {
			nextChar();
			if (this.currentChar == EOF) {
				break;
			}
			iResult &= matchOperand();
		}
		
		return iResult;
	}
	
	private Boolean matchOperand()  {
		Boolean iResult = matchBoolean();
		while (this.currentChar == '(') {
			nextChar();
			if (this.currentChar == EOF) {
				break;
			}
			iResult = matchOr();			
			if (this.currentChar == ')') {
				nextChar();
				return iResult;
			} else {
			    LicenseRuleHelper.logInfo('BooleanExpressionEvaluator', 'matchOperand', '[WARNING] - Expected )');
			}
		}

		return iResult;
	}
	
	private Boolean matchBoolean() {
		Boolean iValue = false;
		String sBoolean = '';
		while (this.currentChar.isAlpha()) {
			sBoolean += this.currentChar;
			nextChar();
			if (this.currentChar == EOF) {
				break;
			}
		}
		
		if (sBoolean.length() > 0 && (sBoolean == 'true' || sBoolean == 'false')) {
			iValue = Boolean.valueOf(sBoolean);
		}
		
		return iValue;
	}

}