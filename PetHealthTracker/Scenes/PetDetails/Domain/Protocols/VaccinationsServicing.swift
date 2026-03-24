//
//  VaccinationsServicing.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 22.03.26.
//

import Foundation

protocol VaccinationsServicing {
    func getVaccinations(petId: String) async throws -> [VaccinationRecordResponse]
    func createVaccination(_ requestModel: CreateVaccinationRequest) async throws -> VaccinationRecordResponse
    func updateVaccination(id: String, requestModel: UpdateVaccinationRequest) async throws -> VaccinationRecordResponse
    func deleteVaccination(id: String) async throws
}
