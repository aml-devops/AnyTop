package com.bytebridges.anytop.service;

import com.bytebridges.anytop.entity.Transaction;
import com.bytebridges.anytop.repository.TransactionRepository;

import lombok.RequiredArgsConstructor;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class ExcelTopupService {

    private final TransactionRepository transactionRepository;

    public int processExcel(MultipartFile file) throws Exception {

        int count = 0;

        try (InputStream is = file.getInputStream();
             Workbook workbook = new XSSFWorkbook(is)) {

            Sheet sheet = workbook.getSheetAt(0);

            for (int i = 1; i <= sheet.getLastRowNum(); i++) {

                Row row = sheet.getRow(i);

                if (row == null) {
                    continue;
                }

                String operator = getCellValue(row.getCell(0));
                String phone = getCellValue(row.getCell(1));
                String amountStr = getCellValue(row.getCell(2));

                if (phone == null || phone.isBlank()) {
                    continue;
                }

                int amount = Integer.parseInt(amountStr);
                Transaction txn = new Transaction();
                txn.setOperator(operator);
                txn.setPhoneNumber(phone);
                txn.setAmount(amount);
                txn.setStatus("");
                txn.setCreatedAt(LocalDateTime.now());

                transactionRepository.save(txn);

                count++;
            }
        }

        return count;
    }

    private String getCellValue(Cell cell) {

        if (cell == null) {
            return "";
        }

        return switch (cell.getCellType()) {

            case STRING -> cell.getStringCellValue();

            case NUMERIC -> {

                double value = cell.getNumericCellValue();

                yield String.valueOf((long) value);
            }

            default -> "";
        };
    }
}
