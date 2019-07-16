class AlavaraHelpers
  def self.originating_address
    Avalara::Request::Address.new({
      address_code: "1",
      postal_code: AVALARA_CONFIGURATION['originating_zip']
    })
  end

  def self.invoice(line:, originating_address:, destination_address:, customer_code:, exemption_no: false)
    invoice_details = {
      doc_date: Time.now,
      doc_type: 'SalesInvoice',
      company_code: AVALARA_CONFIGURATION['company_code'],
      customer_code: customer_code,
      lines: [line],
      addresses: [originating_address, destination_address]
    }

    invoice_details[:exemption_no] = exemption_no if exemption_no
    Avalara::Request::Invoice.new(invoice_details)
  end

  def self.line(amount)
    Avalara::Request::Line.new({
      line_no: "1",
      destination_code: "2",
      origin_code: "1",
      qty: "1",
      amount: amount,
      tax_included: true
    })
  end
end
