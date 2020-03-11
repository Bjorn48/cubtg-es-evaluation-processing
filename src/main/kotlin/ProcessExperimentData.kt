import org.apache.commons.csv.CSVFormat
import org.apache.commons.csv.CSVRecord
import java.io.FileReader
import java.nio.file.Files
import java.nio.file.Path
import java.time.Duration
import java.time.LocalDateTime
import java.util.*

private val configurations = setOf(
    "fit_def_sec_def", "fit_def_sec_max", "fit_def_sec_min", "fit_max_min_sec_def",
    "fit_max_sec_max", "fit_min_sec_min", "nsgaii_max", "nsgaii_min"
)

fun main(args: Array<String>) {
    val statisticsInputFile = args[0]
    val branchCoverageInputFile = args[1]
    val testCaseLengthsInputFile = args[2]
    val testCaseBranchCoverageInputFile = args[3]
    val pitResultFolder = args[4]
    val esLogFolder = args[5]
    val suiteOutputFile = args[6]
    val testCaseOutputFile = args[7]
    val intermediateDataOutputFile = args[8]
    val ratiosOutputPrefix = args[9]

    println("===EvoSuite + PIT output data processor===")
    println(
        """
    Using the following input files and folders:
    *   ES statistics file: $statisticsInputFile
    *   ES suite branch coverage file: $branchCoverageInputFile
    *   ES test case length file: $testCaseLengthsInputFile
    *   PIT report folder: $pitResultFolder
    *   ES log folder: $esLogFolder
""".trimIndent()
    )
    println(
        """
    Using the following output files:
    *   Per test suite data: $suiteOutputFile
    *   Per test case data: $testCaseOutputFile
    *   Intermediate fitness value data: $intermediateDataOutputFile
    *   Ratios between configurations (prefix): $ratiosOutputPrefix
""".trimIndent()
    )

    print("Loading input CSV files...")
    val statisticsCsv = CSVFormat.DEFAULT.withFirstRecordAsHeader().parse(FileReader(statisticsInputFile)).records
    val suiteBranchCoverageCsv = CSVFormat.DEFAULT.parse(FileReader(branchCoverageInputFile)).records
    val testCaseLengthCsv = CSVFormat.DEFAULT.parse(FileReader(testCaseLengthsInputFile)).records
    val testCaseBranchCoverageCsv =
        CSVFormat.DEFAULT.withFirstRecordAsHeader().parse(FileReader(testCaseBranchCoverageInputFile)).records
    println("Done")

    print("Parsing PIT reports...")
    val pitResults = parsePitResults(Path.of(pitResultFolder))
    println("Done")

    print("Extracting branch execution weights...")
    val branchExecWeights = extractBranchExecWeight(suiteBranchCoverageCsv)
    println("Done")

    print("Parsing test case lengths...")
    val testCaseLengths = parseTestCaseLengths(testCaseLengthCsv)
    println("Done")

    print("Parsing branches covered by test cases...")
    val tcCoveredBranches = parseTestCaseCoveredBranches(testCaseBranchCoverageCsv)
    println("Done")

    print("Computing test case execution weight coverage...")
    val tcExecWeightCoverage = computeExecWeightCoverage(tcCoveredBranches, branchExecWeights)
    println("Done")

    print("Extracting intermediate fitness values...")
    val intermediateFitnessValues = extractIntermediateFitnessValues(Path.of(esLogFolder))
    println("Done")

    print("Computing average execution weight per class and configuration...")
    val perClassAndConfAvgExecWeight = computePerClassAndConfAvgExecWeight(tcExecWeightCoverage)
    println("Done")

    print("Compute average execution weight difference ratios between configurations...")
    val defToMaxMaxRatios =
        computeConfExecWeightDiffRatios(perClassAndConfAvgExecWeight, "fit_def_sec_def", "fit_max_sec_max")
    val defToMinMinRatios =
        computeConfExecWeightDiffRatios(perClassAndConfAvgExecWeight, "fit_def_sec_def", "fit_min_sec_min")
    val defToDefMaxRatios =
        computeConfExecWeightDiffRatios(perClassAndConfAvgExecWeight, "fit_def_sec_def", "fit_def_sec_max")
    val defToDefMinRatios =
        computeConfExecWeightDiffRatios(perClassAndConfAvgExecWeight, "fit_def_sec_def", "fit_def_sec_min")
    val defToMaxMinDefRatios =
        computeConfExecWeightDiffRatios(perClassAndConfAvgExecWeight, "fit_def_sec_def", "fit_max_min_sec_def")
    println("Done")

    print("Writing data to disk...")
    outputPerSuiteData(statisticsCsv, pitResults, Path.of(suiteOutputFile))
    outputPerTestCaseData(tcExecWeightCoverage, testCaseLengths, Path.of(testCaseOutputFile))
    outputIntermediateFitnessValueData(intermediateFitnessValues, Path.of(intermediateDataOutputFile))
    outputExecWeightDiffRatios(defToMaxMaxRatios, Path.of("$ratiosOutputPrefix-def-to-max-max.csv"))
    outputExecWeightDiffRatios(defToMinMinRatios, Path.of("$ratiosOutputPrefix-def-to-min-min.csv"))
    outputExecWeightDiffRatios(defToDefMaxRatios, Path.of("$ratiosOutputPrefix-def-to-def-max.csv"))
    outputExecWeightDiffRatios(defToDefMinRatios, Path.of("$ratiosOutputPrefix-def-to-def-min.csv"))
    outputExecWeightDiffRatios(defToMaxMinDefRatios, Path.of("$ratiosOutputPrefix-def-to-max-min-def.csv"))
    println("Done")

    println()
    println("Finished, exiting")
}

data class PitResult(val className: String, val coverageRatio: CoverageRatio)

data class CoverageRatio(val numCovered: Int, val total: Int) {
    fun coverage() = numCovered.toDouble() / total
}

data class Branch(val firstLineNumber: Int, val lastLineNumber: Int)

data class FitnessFunctionValueSnapshot(val esRuntime: Long, val ffName: String, val ffValue: Double)

fun parsePitResults(pitResultFolder: Path): Map<String, PitResult?> {
    val pitResults = mutableMapOf<String, PitResult?>()
    configurations.forEach { configuration ->
        val configurationResultFolder = pitResultFolder.resolve(configuration)
        Files.newDirectoryStream(configurationResultFolder).use {
            it.associateByTo(pitResults, { it.fileName.toString() }, {
                val htmlFile = it.resolve("index.html")
                if (Files.exists(htmlFile)) {
                    val splittedFileName = it.fileName.toString().split('-')
                    val className = splittedFileName[1]
                    val runID = splittedFileName[3]
                    PitResult("$className-$configuration-$runID", parsePitHtmlScore(htmlFile))
                } else
                    null
            })
        }
    }
    return pitResults
}

fun parsePitHtmlScore(pitHtmlResult: Path): CoverageRatio {
    val fileContents = Files.readString(pitHtmlResult)
    val regex =
        Regex("""<h3>Project Summary</h3>\n<table>\n(?:.*\n){7} +<tbody>\n +<tr>\n +<td>\d+</td>\n +<td>.+</td>\n +<td>.+<div class="coverage_legend">(\d+)/(\d+)</div></div></td>""")
    val matchResult = regex.find(fileContents)
        ?: error("PIT result file should look like above regex specifies")
    val killedMutants = matchResult.groups[1]!!.value.toInt()
    val totalMutants = matchResult.groups[2]!!.value.toInt()

    return CoverageRatio(killedMutants, totalMutants)
}

fun outputPerSuiteData(statisticsCsv: List<CSVRecord>, pitResults: Map<String, PitResult?>, outputFile: Path) {
    val printer = CSVFormat.DEFAULT.withHeader(
        "class", "conf", "run-id", "line-coverage", "branch-coverage", "exception-coverage", "weak-mutation-score",
        "method-coverage", "input-coverage", "output-coverage", "suite-size", "num-generations", "pit-score"
    ).print(Files.newBufferedWriter(outputFile))

    statisticsCsv.forEach {
        val splittedConfigurationId = it["configuration_id"].split('-')
        val className = splittedConfigurationId[0]
        val configuration = splittedConfigurationId[1]
        val runID = splittedConfigurationId[2]

        printer.printRecord(
            className, configuration, runID, it["LineCoverage"], it["BranchCoverage"],
            it["ExceptionCoverage"], it["WeakMutationScore"], it["MethodCoverage"], it["InputCoverage"],
            it["OutputCoverage"], it["Size"], it["Generations"],
            pitResults[it["configuration_id"]]?.coverageRatio?.coverage() ?: -1
        )
    }
}

fun extractBranchExecWeight(suiteBranchCoverageCsv: List<CSVRecord>): Map<String, Map<Branch, Int>> =
    suiteBranchCoverageCsv.groupBy {
        it[0].split('-')[0] // Group by class name
    }.mapValues {
        it.value.groupBy {
                it[1] // Group by branch
            }.mapValues { it.value.first()[3].toInt() }
            .mapKeys { // Take first execution weight value, because all are the same
                val splittedKey = it.key.split('-')
                Branch(splittedKey[0].toInt(), splittedKey[1].toInt()) // Change key to Branch object
            }
    }

fun parseTestCaseLengths(testCaseLengthCsv: List<CSVRecord>): Map<String, Int> =
    testCaseLengthCsv.associate { Pair(it[0], it[1].toInt()) }

fun parseTestCaseCoveredBranches(testCaseBranchCoverageCsv: List<CSVRecord>): Map<String, Set<Branch>> =
    testCaseBranchCoverageCsv.filter { it[2] == "true" }.groupBy(
        { it["conf-id"] },
        {
            val splittedLineNumbers = it[1].split('-')
            Branch(splittedLineNumbers[0].toInt(), splittedLineNumbers[1].toInt())
        }
    ).mapValues { it.value.toSet() }

fun computeExecWeightCoverage(
    testCaseCoveredBranches: Map<String, Set<Branch>>,
    branchExecWeights: Map<String, Map<Branch, Int>>
): Map<String, Double> =
    testCaseCoveredBranches.mapValues { (confID, coveredBranches) ->
        val className = confID.split('-')[0]
        computeExecWeightCoverage(
            coveredBranches, branchExecWeights[className]
                ?: error(
                    "This map" +
                            "should contain values for every class"
                )
        )
    }

fun computeExecWeightCoverage(coveredBranches: Set<Branch>, branchExecWeights: Map<Branch, Int>): Double {
    val highestExecWeight = branchExecWeights.values.max() ?: 0
    val lowestExecWeight = branchExecWeights.values.filter { it > 0 }.min() ?: 0

    return coveredBranches.map {
        ((branchExecWeights[it] ?: error("This map should contain values for every branch"))
                - lowestExecWeight) /
                (highestExecWeight - lowestExecWeight).toDouble()
    }.average()
}

fun outputPerTestCaseData(
    testCaseExecWeightCoverage: Map<String, Double>, testCaseLengths: Map<String, Int>,
    outputFile: Path
) {
    val printer = CSVFormat.DEFAULT.withHeader(
        "class", "conf", "run-id", "tc-id", "exec-weight-cov", "length"
    ).print(Files.newBufferedWriter(outputFile))

    testCaseExecWeightCoverage.forEach {
        val splittedTcId = it.key.split('-')
        printer.printRecord(
            splittedTcId[0], splittedTcId[1], splittedTcId[2], splittedTcId[3], it.value,
            testCaseLengths[it.key]
        )
    }
}

fun extractIntermediateFitnessValues(esLogFolder: Path): Map<String, List<FitnessFunctionValueSnapshot>> =
    configurations.map { configuration ->
        val configurationLogFolder = esLogFolder.resolve(configuration)
        Files.newDirectoryStream(configurationLogFolder).use {
            it.filter { it.fileName.toString().endsWith("-out.txt") }.associateBy({
                val splittedFileName = it.fileName.toString().split('-')
                "${splittedFileName[1]}-$configuration-${splittedFileName[2]}"
            },
                { parseEsLogFile(it) })
        }
    }.fold(mutableMapOf(), { merged, confMap ->
        merged.putAll(confMap)
        merged
    })

fun parseEsLogFile(logFile: Path): List<FitnessFunctionValueSnapshot> {
    val ffSnapshots = mutableListOf<FitnessFunctionValueSnapshot>()
    Scanner(Files.newBufferedReader(logFile)).use { scanner ->
        if (!scanner.hasNextLine()) return listOf()
        val startTime = extractEsLogLineTime(scanner.nextLine())
        val fitnessValueRegex =
            Regex("""(?:\[(?:.+)] Best so far \((\d+)\): class \w+(?:\.\w+)+?\.(\w+) \*\* (\d\.\d+))""")
        val execWeightRegex = Regex("""(?:\[(?:.+)] Best so far \((\d+)\): AvgExecCountRatio \*\* (\d\.\d+))""")
        while (scanner.hasNextLine()) {
            val currentLine = scanner.nextLine() ?: error("Just checked if there is a next line")
            val currentLineMatch = fitnessValueRegex.find(currentLine)
            if (currentLineMatch != null) {
                val lineTime = extractEsLogLineTime(currentLine)
                val runtime = Duration.between(startTime, lineTime).toMillis()
                ffSnapshots.add(
                    FitnessFunctionValueSnapshot(
                        runtime, currentLineMatch.groupValues[2],
                        currentLineMatch.groupValues[3].toDouble()
                    )
                )
            } else {
                val execWeightMatch = execWeightRegex.find(currentLine)
                if (execWeightMatch != null) {
                    val lineTime = extractEsLogLineTime(currentLine)
                    val runtime = Duration.between(startTime, lineTime).toMillis()
                    ffSnapshots.add(
                        FitnessFunctionValueSnapshot(
                            runtime, "ExecWeightSuiteFitness",
                            execWeightMatch.groupValues[2].toDouble()
                        )
                    )
                }
            }
        }
    }
    return ffSnapshots
}

fun extractEsLogLineTime(logLine: String): LocalDateTime {
    val startTimeRegex = Regex("""^\[(.+)]""")
    val isoStartTimeString =
        (startTimeRegex.find(logLine)
            ?: error("First log line should always contain time in format regex above"))
            .groups[1]!!.value.replace(' ', 'T').replace(',', '.')
    return LocalDateTime.parse(isoStartTimeString)
}

fun outputIntermediateFitnessValueData(ffValues: Map<String, List<FitnessFunctionValueSnapshot>>, outputFile: Path) {
    val printer = CSVFormat.DEFAULT.withHeader(
        "class-name", "configuration", "run-id", "runtime", "ff-name", "ff-value"
    ).print(Files.newBufferedWriter(outputFile))

    printer.use { innerPrinter ->
        ffValues.forEach { (configurationID, ffValueList) ->
            val splittedConfigurationID = configurationID.split('-')
            ffValueList.forEach {
                innerPrinter.printRecord(
                    splittedConfigurationID[0], splittedConfigurationID[1], splittedConfigurationID[2],
                    it.esRuntime, it.ffName, it.ffValue
                )
            }
        }
    }
}

fun computePerClassAndConfAvgExecWeight(execWeightCov: Map<String, Double>): Map<String, Map<String, Double>> =
    execWeightCov.entries.groupBy { it.key.split('-')[0] }
        .mapValues {
            it.value.groupBy(
                { it.key.split('-')[1] },
                { it.value }
            ).mapValues { it.value.average() }
        }

fun computeConfExecWeightDiffRatios(
    classAndConfAvgExecWeight: Map<String, Map<String, Double>>,
    baseConf: String, compareConf: String
): Map<String, Double> =
    classAndConfAvgExecWeight
        .filter { it.value.containsKey(compareConf) && it.value.containsKey(baseConf) }
        .entries.associateBy({ it.key },
        {
            (it.value[compareConf] ?: error("Just checked containsKey()")) /
                    (it.value[baseConf] ?: error("Just checked containsKey()"))
        })

fun outputExecWeightDiffRatios(ratios: Map<String, Double>, outputFile: Path) {
    val printer = CSVFormat.DEFAULT.withHeader(
        "class-name", "ratio"
    ).print(Files.newBufferedWriter(outputFile))
    ratios.forEach { (className, ratio) -> printer.printRecord(className, ratio) }
}
