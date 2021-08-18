    import XCTest
    @testable import AKCache

    final class AKCacheTests: XCTestCase {
        
        func testAKCache() {
            let cache = AKCache<String, Int>()
            XCTAssertEqual(cache.value(for: "101"), nil)
            cache.insert(key: "101", value: 101)
            XCTAssertEqual(cache.value(for: "101"), 101)
            cache.remove(key: "101")
            XCTAssertEqual(cache.value(for: "101"), nil)
        }
        
        func testSubscript() {
            let cache = AKCache<String, Int>()
            XCTAssertEqual(cache["101"], nil)
            cache["101"] = 101
            XCTAssertEqual(cache["101"], 101)
            cache["101"] = nil
            XCTAssertEqual(cache["101"], nil)
        }
        
        func testLifeTime() {
            let cache = AKCache<Int, String>.init(dateProvider: { Date.init() }, entryLifeTime: 30)
            XCTAssertEqual(cache[101], nil)
            cache[101] = "101"
            XCTAssertEqual(cache[101], "101")
            let expect = expectation(description: "Test cache invalidation condition")
            Timer.scheduledTimer(withTimeInterval: 31, repeats: false, block: {timer in
                expect.fulfill()
                timer.invalidate()
            })
            wait(for: [expect], timeout: 32)
            XCTAssertEqual(cache[101], nil)
        }
        
        func testKeyTracker() {
            let cache = AKCache<String, Int>()
            XCTAssertEqual(cache.isKeyExist(key: "101"), false)
            cache.insert(key: "101", value: 101)
            XCTAssertEqual(cache.isKeyExist(key: "101"), true)
            cache.remove(key: "101")
            XCTAssertEqual(cache.isKeyExist(key: "101"), false)
        }
        
        func testPersistentStorage() {
            let cache = AKCache<String, Int>()
            cache["101"] = 101
            cache["102"] = 102
            cache["103"] = 103
            cache["104"] = 104
            
            do {
                try cache.saveToDisk(withName: "Abhilash")
            } catch {
                XCTFail("Failed to save the cache to disk with msg: \(error)")
            }
            
            XCTAssertEqual(FileManager.default.fileExists(atPath: "/Users/futuretrunks/Library/Caches/Abhilash.cache"), true)
            do {
               try? FileManager.default.removeItem(atPath: "/Users/futuretrunks/Library/Caches/Abhilash.cache")
            }
        }
        
        func testRefetchCacheFromDisk() {
            let cache = AKCache<String, Int>()
            cache["101"] = 101
            cache["102"] = 102
            cache["103"] = 103
            cache["104"] = 104
            
            do {
                try cache.saveToDisk(withName: "Abhilash")
            } catch {
                XCTFail("Failed to save the cache to disk with msg: \(error)")
            }
            
            XCTAssertEqual(FileManager.default.fileExists(atPath: "/Users/futuretrunks/Library/Caches/Abhilash.cache"), true)
            cache.removeAll()
            XCTAssertEqual(cache.isKeyExist(key: "101"), false)
            XCTAssertEqual(cache.isKeyExist(key: "102"), false)
            XCTAssertEqual(cache.isKeyExist(key: "103"), false)
            XCTAssertEqual(cache.isKeyExist(key: "104"), false)
            
            do {
                try cache.readFromDisk(withName: "Abhilash")
            } catch {
                XCTFail("Failed to save the cache to disk with msg: \(error)")
            }
            XCTAssertEqual(cache["101"], 101)
            XCTAssertEqual(cache["102"], 102)
            XCTAssertEqual(cache["103"], 103)
            XCTAssertEqual(cache["104"], 104)
        }
    }
