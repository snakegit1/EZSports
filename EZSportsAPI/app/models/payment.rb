require 'avatax'
require 'date'
require 'yaml'

class Payment < ActiveRecord::Base

    def avalara_get_tax(league, amount, cc_id, exemption_no = false)
        path = File.join(Rails.root, 'config', 'avalara.yml')
        config = YAML.load_file(path)[Rails.env]
        now = Time.now.strftime("%Y-%m-%d")
        p 'END: ' + config['endpoint']
        p league[:zip]
        p now

        AvaTax.configure do
            account_number config['username']
            license_key config['password']
            service_url config['endpoint']
        end

        taxSvc = AvaTax::TaxService.new

        getTaxRequest = {
          # Document Level Elements
          # Required Request Parameters
          :CustomerCode => config['company_code'],
          :DocDate => now,
        # :DocDate => 'blarg',
          # Best Practice Request Parameters
        #   :CompanyCode => cc_id.to_s,
          :Client => "Efficient Solutions",
          :DetailLevel => "Tax",
          :Commit => true,
          :DocType => "SalesInvoice",

          # Address Data
          :Addresses =>
          [
            {
              :AddressCode => "01",
              :PostalCode => config['originating_zip']
            },
            {
              :AddressCode => "02",
              :PostalCode => league[:zip]
            }
          ],

          # Line Data
          :Lines =>
          [
            {
            # Required Parameters
            :LineNo => "01",
            :ItemCode => "EZ-Active",
            :Qty => 1,
            :Amount => amount,
            :OriginCode => "01",
            :DestinationCode => "02",

            # Best Practice Request Parameters
            :Description => cc_id.to_s,
            :TaxCode => "NT"
            }

          ]
        }

        p 'TAX REQUEST'
        p getTaxRequest

        getTaxResult = taxSvc.get(getTaxRequest)

        # Print Results
        puts "getTax ResultCode: " + getTaxResult["ResultCode"]
        if getTaxResult["ResultCode"] != "Success"
          getTaxResult["Messages"].each { |message| puts message["Summary"] }
        else
          puts "Document Code: " + getTaxResult["DocCode"] + " Total Tax: " + getTaxResult["TotalTax"].to_s
          getTaxResult["TaxLines"].each do |taxLine|
              puts "    " + "Line Number: " + taxLine["LineNo"] + " Line Tax: " + taxLine["Tax"].to_s
              taxLine["TaxDetails"].each do |taxDetail|
                  puts "        " + "Jurisdiction: " + taxDetail["JurisName"] + " Tax: " + taxDetail["Tax"].to_s
              end
          end
        end
        puts "Generated DocCode: " + getTaxResult["DocCode"].to_s

        return getTaxResult
    end



  def calculate_tax(league, amount, cc_id, exemption_no = false)
      p 'CALCULATING TAX'
    line = AlavaraHelpers.line(amount)
    invoice = AlavaraHelpers.invoice(
      line: line,
      originating_address: AlavaraHelpers.originating_address,
      destination_address: avalara_address(league.zip),
      customer_code: cc_id,
      exemption_no: exemption_no
    )

    p 'AVALARA INVOICE'
    p invoice

    result = Avalara.get_tax(invoice)
    p 'AVALARA RESULT'
    p result

    if result.result_code == 'Success'
      self[:tax] = result.total_tax_calculated
      save
    else
      raise 'Tax could not be calculated'
    end

    return result
  end

  private def avalara_address(zip)
    Avalara::Request::Address.new({
      address_code: "2",
      postal_code: zip
    })
  end
end
