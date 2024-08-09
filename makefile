# Makefile
PHONY: create_template

clear:
	@rm -rf ex*
	@rm -rf test.sh
	@rm -rf .gitignore
	@rm -rf locked/ex*
	@rm -rf locked/cases/*
	@echo "All files have been removed successfully."

create_c:
	@for idx in $$(seq 1 $$(($$BASIC + $$ADVANCED))); do \
		padded_session=$(shell printf "%02d" $(SESSION)); \
		echo "Creating file ex$${padded_session}_$${idx}.c"; \
		touch "ex$${padded_session}_$${idx}.c"; \
	done

update_submit:
	@# Update submit.sh
	@echo "Building issue files list"
	@echo -n "BASIC_TARGET_FILES=(" > basic_target_files.tmp
	@echo -n "ADVANCED_TARGET_FILES=(" > advanced_target_files.tmp
	@for idx in $$(seq 1 $(BASIC)); do \
		padded_session=$$(printf "%02d" $(SESSION)); \
		file="ex$${padded_session}_$${idx}.c"; \
		if [ $${idx} -eq $(BASIC) ]; then \
			echo -n "\"$$file\"" >> basic_target_files.tmp; \
		else \
			echo -n "\"$$file\" " >> basic_target_files.tmp; \
		fi \
	done
	@for idx in $$(seq 1 $(ADVANCED)); do \
		padded_session=$$(printf "%02d" $(SESSION)); \
		file="ex$${padded_session}_$$(($$idx + $$BASIC)).c"; \
		if [ $${idx} -eq $(ADVANCED) ]; then \
			echo -n "\"$$file\"" >> advanced_target_files.tmp; \
		else \
			echo -n "\"$$file\" " >> advanced_target_files.tmp; \
		fi \
	done
	@echo ")" >> basic_target_files.tmp
	@echo ")" >> advanced_target_files.tmp

	@# Insert basic issue files into the fifth line of submit.sh
	@echo "Updating submit.sh"
	@sed -i '5r basic_target_files.tmp' submit.sh
	@sed -i '5d' submit.sh

	@# Insert advanced issue files into the fifth line of submit.sh
	@echo "Updating submit.sh"
	@sed -i '8r advanced_target_files.tmp' submit.sh
	@sed -i '8d' submit.sh

	@# Update the commit message
	@echo "Updating commit message"
	# @sed -i '11s/.*/COMMIT_MESSAGE="ex$(SESSION)"/' submit.sh
	@sed -i '11s/.*/COMMIT_MESSAGE="ex$(shell printf "%02d" $(SESSION)) submit"/' submit.sh

	@# Remove the temporary file
	@rm -f basic_target_files.tmp advanced_target_files.tmp

update_readme:
	@# Update README.md
	@echo "Updating README.md"
	@sed -i '1s/.*/# プログラミング演習 Ⅱ 第 $(SESSION) 回/' README.md

create_testshell:
	@# Create and modify dynamic shell scripts
	@echo "Creating and modifying dynamic shell scripts"
	@for idx in $$(seq 1 $$(($$BASIC + $$ADVANCED))); do \
		padded_session=$$(printf "%02d" $(SESSION)); \
		script_file="./locked/ex$${padded_session}_$${idx}.sh"; \
		cp "./locked/test_template.sh" "$$script_file"; \
		sed -i "3s/.*/C_FILE=ex$${padded_session}_$${idx}.c/" "$$script_file"; \
		sed -i "4s/.*/EXE_FILE=ex$${padded_session}_$${idx}/" "$$script_file"; \
	done

create_testall:
	@# Copy local_test_template.sh to create test.sh
	@cp local_test_template.sh test.sh
	@chmod +x test.sh

	@# Modify the 4th line of test.sh
	@SUM=$$(( $(BASIC) + $(ADVANCED) )); \
	sed -i "4s/.*/kadai_numbers=$$SUM/" test.sh
	@echo "" >> test.sh
	@for idx in $$(seq 1 $$(($$BASIC + $$ADVANCED))); do \
		padded_session=$$(printf "%02d" $(SESSION)); \
		echo "if [ \"\$$kadai_number\" = \"$${idx}\" ] || [ \"\$$kadai_number\" = \"all\" ]; then" >> test.sh; \
		echo "    echo \"Start testing ex$${padded_session}_$${idx}.c\"" >> test.sh; \
		echo "    ./locked/ex$${padded_session}_$${idx}.sh local" >> test.sh; \
		echo "fi" >> test.sh; \
		echo "" >> test.sh; \
	done
	@echo "# 終了" >> test.sh
	@echo "echo \"All tests have been completed !!\"" >> test.sh
	@echo "exit 0" >> test.sh

create_testcase_dir:
	@# Create directories
	@for idx in $$(seq 1 $$(($$BASIC + $$ADVANCED))); do \
		padded_session=$$(printf "%02d" $(SESSION)); \
		dir_path="./locked/cases/ex$${padded_session}_$$idx"; \
		echo "Creating directories in: $$dir_path"; \
		mkdir -p $$dir_path/in $$dir_path/out; \
		for file_idx in $$(seq -w 0 4); do \
			touch $$dir_path/in/$$file_idx.txt; \
			touch $$dir_path/out/$$file_idx.txt; \
			echo "Files created: $$dir_path/in/$$file_idx.txt and $$dir_path/out/$$file_idx.txt"; \
		done; \
	done

create_template: create_c update_submit update_readme create_testshell create_testall create_testcase_dir
	@echo "All files have been created successfully."

test_hash:
	gcc -o ${ASSIGNMENT} ${ASSIGNMENT}.c
	@if [ $$? -ne 0 ]; then \
		echo "Failed to compile ${ASSIGNMENT}.c"; \
		exit 1; \
	fi
	@mkdir -p ${ASSIGNMENT}_test
	@for input_file in ./locked/cases/${ASSIGNMENT}/in/*.txt; do \
		echo $$input_file; \
		output_file=$$(echo $$input_file | sed -e "s/in/out/"); \
		echo $$output_file; \
		./${ASSIGNMENT} < $$input_file | tr -d ' \t\n' > $$output_file;\
		cp $$output_file ./${ASSIGNMENT}_test; \
		filename=$$(basename $$output_file); \
		shasum -a 256 ./${ASSIGNMENT}_test/$$filename | awk '{print $$1}' > $$output_file; \
	done

test_hash_no_input:
	gcc -o ${ASSIGNMENT} ${ASSIGNMENT}.c
	@if [ $$? -ne 0 ]; then \
		echo "Failed to compile ${ASSIGNMENT}.c"; \
		exit 1; \
	fi
	@mkdir -p ${ASSIGNMENT}_test
	output_file=./locked/cases/${ASSIGNMENT}/out/0.txt; \
	./${ASSIGNMENT} | tr -d ' \t\n' > $$output_file;\
	cp $$output_file ./${ASSIGNMENT}_test; \
	filename=$$(basename $$output_file); \
	shasum -a 256 ./${ASSIGNMENT}_test/$$filename | awk '{print $$1}' > $$output_file; \
