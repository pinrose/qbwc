# Quickbooks Web Connector (QBWC)

Be Warned, this code is still hot out of the oven. 

## Installation

Install the gem

  `gem install qbwc`

Add it to your Gemfile

  `gem "qbwc"`

Run the generator:

  `rails generate qbwc:install`
  
  `rake db:migrate`

## Features

QBWC was designed to add quickbooks web connector integration to your Rails 3 application. 

* Implementation of the Soap WDSL spec for Intuit Quickbooks and Point of Sale
* Integration with the [qbxml](https://github.com/pinrose/qbxml) gem providing qbxml processing

## Getting Started

### Configuration

All configuration takes place in the gem initializer. See the initializer for more details regarding the configuration options.

### Basics

The QBWC gem provides a persistent work queue for the Web Connector to talk to.

Every time the Web Connector initiates a new conversation with the application a
Session will be created. The Session is a collection of jobs and the requests
that comprise these jobs. A new Session will automatically queue up all the work
available across all currently enabled jobs for processing by the web connector.
The session instance will persist across all requests until the work it contains
has been exhausted. You never have to interact with the Session class directly
(unless you want to...) since creating a new job will automatically add it's
work to the next session instance.

A Job is just a named work queue. It consists of a name, a company (defaults to QBWC.company_file_path), and some qbxml requests. If requests are not provided, a code block that generates next qbxml request can be provided.

*Note: All requests may be in ruby hash form, generated qbxml
Raw requests are supported supported as of 0.0.3 (8/28/2012)*

Only enabled jobs with pending requests are added to a new session instance. Pending requests is checked calling code block, but an optional pending requests checking block can also be added to a job, so request creation can be avoided.

An optional response processor block can also be added to a job. Responses to
all requests are processed immediately after being received.

Here is the rough order in which things happen:

  1. The Web Connector initiates a connection
  2. A new Session is created (with work from all enabled jobs with pending requests)
  3. The web connector requests work
  4. The session responds with the next request in the work queue
  5. The web connector provides a response
  6. The session responds with the current progress of the work queue (0 - 100)
  6. The response is processed
  7. If progress == 100 then the web connector closes the connection, otherwise goto 3

### Get Your App Ready

Create a new class or use a rails model

    class Order < ActiveRecord::Base
      include QBWC::ModelMethods
      
      def qb_payload
        # A receipt request hash payload
        {
          'sales_receipt_add_rq' => {
            'xml_attributes' => {
                'requestID' => self.number
            },
            'sales_receipt_add' => {
                'customer_ref' => {
                    'full_name' => 'Pinrose'
                },
                'class_ref' => {
                    'full_name' => 'Online Sales'
                },
                'template_ref' => {
                  'full_name' => 'Custom Sales Receipt'
                },
                'txn_date' => self.completed_at.strftime("%Y-%m-%d"),
                'ref_number' => self.number,
                'bill_address' => { #... },
                'ship_address' => { #... },
                'is_pending' => false,
                'payment_method_ref' => { #... },
                'memo' => 'This is a memo for the receipt',
                'is_to_be_printed' => false,
                'is_to_be_emailed' => false,
                'sales_receipt_line_add' => [
                  #...,
                  #...,
                  #...,
                ]
            }
          }
        }
      end
      
      def qb_response_handler(response)
        # Do something with the response sent back to you
      end

    end

### Adding Jobs

Create a new job (Example above continued)

    order = Order.find(1)
    order.qb_queue # returns false if it couldn't be saved or returns the job.
    QBWC::QbwcJob.all
    [#<QBWC::QbwcJob id: 1, klass: "Order", klass_id: 1, company: nil, processed: false, created_at: "2014-06-18 23:49:35", updated_at: "2014-16-18 23:49:35">]
    # Next, run your Web Connector and it will pick it up.
    
### Set up your web connector

You'll have a call to get your QWC file at:

    https://www.yourdomain.com/qbwc/qwc
    
Enter that after you open Web Connector and click 'Add an Application'. Your ssl cert will need to be confirmed. Set your password, check the box to the left and click 'Update Selected'

The Web Connector should pull in your job and run it.

If you are working in development mode on a local machine, download, install and run ngrok - https://ngrok.com/
    
### Supporting multiple users/companies

Coming soon.

## Contributing to qbwc
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.
