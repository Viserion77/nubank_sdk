# frozen_string_literal: true

module Graphql
  class Account
    BALANCE = '{viewer {savingsAccount {currentSavingsBalance {netAmount}}}}'
    FEED = <<~GRAPHQL
      {
        viewer {
          savingsAccount {
            id
            feed {
              id
              __typename
              title
              detail
              postDate
              ... on TransferInEvent {
                amount
                originAccount {
                  name
                }
              }
              ... on TransferOutEvent {
                amount
                destinationAccount {
                  name
                }
              }
              ... on TransferOutReversalEvent {
                amount
              }
              ... on BillPaymentEvent {
                amount
              }
              ... on DebitPurchaseEvent {
                amount
              }
              ... on BarcodePaymentEvent {
                amount
              }
              ... on DebitWithdrawalFeeEvent {
                amount
              }
              ... on DebitWithdrawalEvent {
                amount
              }
            }
          }
        }
      }
    GRAPHQL
  end
end
