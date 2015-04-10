require 'spec_helper'

describe Remitano::Orders do
  describe :all, vcr: {cassette_name: 'remitano/orders/all'} do
    subject { Remitano.orders.all }
    it { should be_kind_of Array }
    describe "first order" do
      subject { Remitano.orders.all.first }
      its(:price) { should == "372.04" }
      its(:quantity) { should == "1.5" }
      its(:order_type) { should == "limit" }
      its(:created_at) { should == "2015-03-09T09:11:37.060Z" }
    end
  end

  describe :live, vcr: {cassette_name: 'remitano/orders/live'} do
    subject { Remitano.orders.live }
    it { should be_kind_of Array }
    describe "first order" do
      subject { Remitano.orders.live.first }
      its(:price) { should == 238.4 }
      its(:quantity) { should == 2.6926 }
      its(:order_type) { should == "limit" }
      its(:created_at) { should == "2015-04-10T03:25:08.339Z" }
      its(:status) { should == "live" }
    end
  end

  describe :create, vcr: {cassette_name: 'remitano/orders/create'} do
    subject { Remitano.orders.create(side: "sell", order_type: "limit", :quantity => 1.2, :price => 350) }
    its(:price) { should == 350.0 }
    its(:side) { should == "sell" }
    its(:quantity) { should == 1.2 }
    its(:order_type) { should == "limit" }
  end

  describe :cancel, vcr: {cassette_name: 'remitano/orders/cancel'} do
    subject { Remitano.orders.cancel(72, 73) }

    it "cancel multiple orders" do
      subject.count.should == 2
      subject.first.id.should == 72
      subject.first.status.should == "cancelled"
      subject.second.id.should == 73
      subject.second.status.should == "cancelled"
    end
  end

  describe :get, vcr: {cassette_name: 'remitano/orders/get'} do
    subject { Remitano.orders.get(1, 2, 3) }

    it "returns multiple orders" do
      subject.count.should == 3
      subject.first.id.should == 1
      subject.first.order_type.should == "market"
      subject.first.status.should == "cancelled"

      subject.second.id.should == 2
      subject.second.order_type.should == "limit"
      subject.second.price.should == 372.04
      subject.second.status.should == "cancelled"

      subject.third.id.should == 3
      subject.third.order_type.should == "limit"
      subject.third.price.should == 350.0
      subject.third.status.should == "filled"
    end
  end
end
