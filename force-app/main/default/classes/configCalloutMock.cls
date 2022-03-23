/*
***********************************************************************************************************************************
Class Name: configCalloutMock
@author: Ashwin.A.
@date :  22-03-2022

*************************************************************************************************************************************
*/
@isTest
global class configCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"case": {"id":2, "name":"Test"}}');
        response.setStatusCode(200);
        return response; 
    }
}