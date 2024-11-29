/**
 * Copyright (c) HashiCorp, Inc.
 * SPDX-License-Identifier: MPL-2.0
 */

// Lambda function code

module.exports.handler = async (event) => {
  console.log('Event: ', event);
  let responseMessage = 'Payment Confirmed!!!';
  console.log('Checking Payment info....');

  if (event.queryStringParameters && event.queryStringParameters['Name']) {
      responseMessage = 'Hello, ' + event.queryStringParameters['Name'] + '!';
    }
  console.log('Sending payment confirmation');
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: responseMessage,
    }),
  }
}
