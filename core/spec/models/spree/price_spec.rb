require 'spec_helper'

describe Spree::Price do
  describe 'validations' do
    let(:variant) { stub_model Spree::Variant }
    let(:amount) { nil }
    subject { Spree::Price.new variant: variant, amount: amount }

    context 'when the amount is nil' do
      it { should be_valid }
    end

    context 'when the amount is less than 0' do
      let(:amount) { -1 }

      it { should have(1).error_on(:amount) }
      it 'populates errors' do
        subject.valid?
        expect(subject.errors.messages[:amount].first).to eq 'must be greater than or equal to 0'
      end
    end

    context 'when the amount is greater than 999,999.99' do
      let(:amount) { 1_000_000 }

      it { should have(1).error_on(:amount) }
      it 'populates errors' do
        subject.valid?
        expect(subject.errors.messages[:amount].first).to eq 'must be less than or equal to 999999.99'
      end
    end

    context 'when the amount is between 0 and 999,999.99' do
      let(:amount) { 100 }
      it { should be_valid }
    end

    context 'when the variant is nil' do
      let(:variant) { nil }

      it { should have(1).error_on(:variant_id) }
      it 'populates errors' do
        subject.valid?
        expect(subject.errors.messages[:variant_id].first).to eq "can't be blank"
      end
    end
  end
end
