@isTest
private class BooleanExpressionEvaluatorTest {
    
    static testmethod void testValidBooleanExpressionEvaluatorTest() {
    	String testStr1 = 'true';
    	BooleanExpressionEvaluator eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(true, eval.eval());
    	
    	testStr1 = '(true)';
    	eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(true, eval.eval());
    	
    	testStr1 = '(true | false)';
    	eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(true, eval.eval());
    	
    	testStr1 = '((true | false) & true)';
    	eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(true, eval.eval());
    	
    	testStr1 = '((false | false) & (true | false))';
    	eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(false, eval.eval());
    	
    	testStr1 = '(true | (true | (true|false))) | false';
    	eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(true, eval.eval());
    	
    	testStr1 = 'false & (true | (true | (true|false)))';
    	eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(false, eval.eval());
    	
    }
    
    static testmethod void testInvalidBooleanExpressionEvaluatorTest() {
    	String testStr1 = '(';
    	BooleanExpressionEvaluator eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(false, eval.eval());
    	
    	testStr1 = '|';
    	eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(false, eval.eval());
    	
    	testStr1 = 'f';
    	eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(false, eval.eval());
    	
    	testStr1 = '';
    	eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(false, eval.eval());
    	
    	testStr1 = '(true';
    	eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(true, eval.eval());
    	
    	testStr1 = 'true & ';
    	eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(true, eval.eval());
    	
    	testStr1 = 'false)';
    	eval = new BooleanExpressionEvaluator(testStr1);
    	System.assertEquals(false, eval.eval());
    	
    }
}