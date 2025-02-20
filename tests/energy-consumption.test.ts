import { describe, it, expect, beforeEach } from "vitest"

describe("Energy Consumption Contract", () => {
  const mockStorage = new Map<string, any>()
  let nextConsumerId = 1
  let totalConsumption = 0
  
  beforeEach(() => {
    mockStorage.clear()
    nextConsumerId = 1
    totalConsumption = 0
  })
  
  const mockContractCall = (method: string, args: any[]) => {
    switch (method) {
      case "register-consumer":
        const consumerId = nextConsumerId++
        mockStorage.set(`consumer-${consumerId}`, { total_consumption: 0 })
        return { success: true, value: consumerId }
      case "record-consumption":
        const [id, amount] = args
        const consumer = mockStorage.get(`consumer-${id}`)
        if (!consumer) return { success: false, error: "Consumer not found" }
        consumer.total_consumption += amount
        totalConsumption += amount
        mockStorage.set(`consumer-${id}`, consumer)
        return { success: true }
      case "get-consumer-info":
        return { success: true, value: mockStorage.get(`consumer-${args[0]}`) }
      case "get-total-consumption":
        return { success: true, value: totalConsumption }
      default:
        return { success: false, error: "Method not found" }
    }
  }
  
  it("should register a consumer", async () => {
    const result = mockContractCall("register-consumer", [])
    expect(result.success).toBe(true)
    expect(result.value).toBe(1)
  })
  
  it("should record consumption", async () => {
    mockContractCall("register-consumer", [])
    const result = mockContractCall("record-consumption", [1, 50])
    expect(result.success).toBe(true)
  })
  
  it("should get consumer info", async () => {
    mockContractCall("register-consumer", [])
    mockContractCall("record-consumption", [1, 50])
    const result = mockContractCall("get-consumer-info", [1])
    expect(result.success).toBe(true)
    expect(result.value.total_consumption).toBe(50)
  })
  
  it("should get total consumption", async () => {
    mockContractCall("register-consumer", [])
    mockContractCall("record-consumption", [1, 50])
    const result = mockContractCall("get-total-consumption", [])
    expect(result.success).toBe(true)
    expect(result.value).toBe(50)
  })
})

